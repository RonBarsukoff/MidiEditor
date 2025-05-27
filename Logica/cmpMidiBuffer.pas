unit cmpMidiBuffer;

interface
uses
  Types,
  Classes;

type
  TMidiBuffer = class(TObject)
  private
    FBuffer: TByteDynArray;
    FBufferIndex: Integer;
    FNumBytesWrittenInTrack: Integer;
    FPlaceMarkerInTrack: Integer;
    procedure BeginWrite(aAantalBytes: Integer); // zorgt er voor dat er minimaal aAantalBytes toegevoegd kunnen worden
    procedure EndWrite(aAantalBytes: Integer); // verhoogt FBufferIndex en  FNumBytesWrittenInTrack
    procedure WriteBuffer(const aBuffer; aAantalBytes: integer); //deprecated;
  public
    procedure Add1ByteEvent(aDeltaTime: LongInt; aSoort, aKanaal: integer; aData1: byte);
    procedure Add2ByteEvent(aDeltaTime: LongInt; aSoort, aKanaal: integer; aData1, aData2: byte);
    procedure AddMetaEvent(aDeltaTime: LongInt; aSoort: word; aData: PAnsiChar; aSize: LongInt); overload; //deprecated;
    procedure AddMetaEvent(aDeltaTime: LongInt; aSoort: word; aData: AnsiString); overload;
    procedure AddKeySignature(aDeltaTime: LongInt; aAantalKruisen: integer; aMajeur: boolean);
    procedure AddTimeSignature(aDeltaTime: LongInt; aTeller, aNoemer: integer);
    procedure AddTempo(aDeltaTime: LongInt; aTempo: LongInt);
    procedure NewTrack;
    procedure EndTrack;
    procedure WriteVarLen(aValue: LongInt);
    procedure Reset;
    procedure WriteByte(aValue: Byte);
    procedure WriteInt32(aValue: Int32);
    procedure WriteInt16(aValue: Int16);
    procedure WriteAnsiString(aValue: AnsiString);
    procedure SchrijfNaarFile(const aFilename: String);
  end;

implementation
uses
  SysUtils,
  uMidiConstants;

procedure TMidiBuffer.Reset;
begin
  FBufferIndex := 0;
  SetLength(FBuffer, FBufferIndex);
end;

procedure TMidiBuffer.Add1ByteEvent(aDeltaTime: LongInt; aSoort, aKanaal: integer; aData1: byte);
begin
  WriteVarLen(aDeltaTime);
  WriteByte(aSoort or aKanaal);
  WriteByte(aData1);
end;

procedure TMidiBuffer.Add2ByteEvent(aDeltaTime: LongInt; aSoort, aKanaal: integer; aData1, aData2: byte);
begin
  WriteVarLen(aDeltaTime);
  WriteByte(aSoort or aKanaal);
  WriteByte(aData1);
  WriteByte(aData2);
end;

procedure TMidiBuffer.AddMetaEvent(aDeltaTime: LongInt; aSoort: word; aData: PAnsiChar; aSize: LongInt);
begin
  WriteVarLen(aDeltaTime);
  WriteByte(meta_event);
  WriteByte(aSoort);
  WriteVarLen(aSize);
  WriteBuffer(aData^, aSize);
end;

procedure TMidiBuffer.AddMetaEvent(aDeltaTime: LongInt; aSoort: word; aData: AnsiString);
begin
  WriteVarLen(aDeltaTime);
  WriteByte(meta_event);
  WriteByte(aSoort);
  WriteVarLen(Length(aData));
  WriteAnsiString(aData);
end;

procedure TMidiBuffer.WriteVarLen(aValue: LongInt);
var
  myBuffer: LongInt;
begin
  myBuffer := aValue and $7f;
  aValue := aValue shr 7;
  while aValue > 0 do
  begin
    myBuffer := myBuffer shl 8;
    myBuffer := myBuffer or $80;
    myBuffer := myBuffer + aValue and $7f;
    aValue := aValue shr 7;
  end;
  while true do
  begin
    WriteByte(myBuffer and $ff);
    if myBuffer and $80 <> 0 then
      myBuffer := myBuffer shr 8
    else
      Exit;
  end;
end;

procedure TMidiBuffer.BeginWrite(aAantalBytes: Integer);
begin
  if FBufferIndex + aAantalBytes > Length(FBuffer) then
    SetLength(FBuffer, Length(FBuffer) + 1024);
end;

procedure TMidiBuffer.EndWrite(aAantalBytes: Integer);
begin
  Inc(FBufferIndex, aAantalBytes);
  Inc(FNumBytesWrittenInTrack, aAantalBytes);
end;

procedure TMidiBuffer.WriteBuffer(const aBuffer; aAantalBytes: integer);
begin
  BeginWrite(aAantalBytes);
  Move(aBuffer, FBuffer[FBufferIndex], aAantalBytes);
  EndWrite(aAantalBytes);
end;

procedure TMidiBuffer.WriteByte(aValue: Byte);
begin
  BeginWrite(1);
  FBuffer[FBufferIndex] := aValue;
  EndWrite(1);
end;

procedure TMidiBuffer.WriteInt32(aValue: Int32);
var
  I: Integer;
type
  T4Bytes = array[0..3] of Byte;
begin
  BeginWrite(4);
  for I := 0 to 3 do
    FBuffer[FBufferIndex+I] := T4Bytes(aValue)[3-I];
  EndWrite(4);
end;

procedure TMidiBuffer.WriteInt16(aValue: Int16);
var
  I: Integer;
type
  T2Bytes = array[0..1] of Byte;
begin
  BeginWrite(2);
  for I := 0 to 1 do
    FBuffer[FBufferIndex+I] := T2Bytes(aValue)[1-I];
  EndWrite(2);
end;

procedure TMidiBuffer.WriteAnsiString(aValue: AnsiString);
var
  I: Integer;
begin
  BeginWrite(Length(aValue));
  for I := 1 to Length(aValue) do
    FBuffer[FBufferIndex+I-1] := Byte(aValue[I]);
  EndWrite(Length(aValue));
end;

procedure TMidiBuffer.AddKeySignature(aDeltaTime: LongInt; aAantalKruisen: integer; aMajeur: boolean);
var D: array[0..1] of AnsiChar;
begin
  D[0] := AnsiChar(aAantalKruisen);
  if aMajeur then
    D[1] := #0
  else
    D[1] := #1;
  AddMetaEvent(aDeltaTime, key_signature, D, 2);
end;

function Macht(N: integer): integer;
begin
  Result := 0;
  while N > 1 do
  begin
    Inc(Result);
    N := N div 2;
  end;
end;

procedure TMidiBuffer.AddTimeSignature(aDeltaTime: LongInt; aTeller, aNoemer: integer);
var D: array[0..3] of AnsiChar;
begin
  D[0] := AnsiChar(aTeller);
  D[1] := AnsiChar(Macht(aNoemer));
  D[2] := AnsiChar(24*4 div aNoemer); { zie mid-frm1.txt van de muziekschijf van PCM }
  D[3] := AnsiChar(8);
  AddMetaEvent(aDeltaTime, time_signature, D, 4);
end;

procedure TMidiBuffer.AddTempo(aDeltaTime: LongInt; aTempo: LongInt);
begin
  WriteVarLen(aDeltaTime);
  WriteByte(meta_event);
  WriteByte(set_tempo);
  WriteByte(3);
  WriteByte($ff and (aTempo shr 16));
  WriteByte($ff and (aTempo shr 8));
  WriteByte($ff and aTempo);
end;

procedure TMidiBuffer.SchrijfNaarFile(const aFilename: String);
var
  S: TStream;
{$ifdef fpc}
  I: Integer;
{$endif}
begin
  S := TFileStream.Create(aFileName, fmCreate);
{$ifdef fpc}
  for I := 0 to FBufferIndex-1 do
    S.WriteByte(FBuffer[I]);
{$else}
  S.WriteBuffer(FBuffer, FBufferIndex);
{$endif}
  S.Free;
end;

procedure TMidiBuffer.NewTrack;
var
  myDummy: Int32;
begin
  WriteAnsiString(MTrk);
  FPlaceMarkerInTrack := FBufferIndex;
  myDummy := -1;
  WriteInt32(myDummy); { zomaar een Longint, wordt overschreven in EndTrack }
  FNumBytesWrittenInTrack := 0;
end;

procedure TMidiBuffer.EndTrack;
var
  myPlaceMarker: Integer;
  I: Integer;
begin
  WriteByte(0);
  WriteByte(meta_event);
  WriteByte(end_of_track);
  WriteByte(0);
  myPlaceMarker := FBufferIndex;
  FBufferIndex := FPlaceMarkerInTrack;
  I := FNumBytesWrittenInTrack;
  WriteInt32(I);
  FBufferIndex := myPlaceMarker;
end;

end.
