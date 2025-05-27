unit cmpMidiLezer;

interface
uses
  uTypes,
  uMidiConstants,
  cmpMidiObject;

type
  TMidiLezer = class(TObject)
  private
    Mf_currtime: TTijd; { current time in delta-time units                   }
    Mf_toberead: LongInt;
    FMsgBuffer: AnsiString;
    FMsgBytes: array of Byte;
    FMidiObject: TMidiObject;
    FTrack: TMidiTrack; { aktuele track }
    F: File; { de inputfile }
    LogFile: TextFile;
    LogFileName: String;
    FUseLogfile: boolean;
    function LeesSignature: AnsiString;
    function EGetc: Byte;
    function ReadVariNum: LongInt;
    function Read32Bit: LongInt;
    function Read16Bit: integer;
    procedure ChanMessage(Status, C1, C2: integer);
    procedure MetaEvent(Soort: integer);
    procedure ReadHeader;
    function ReadTrack: boolean;
//    function LeesCASM: boolean;

    procedure Log(const S: String);
    procedure Mf_Header(aFormaat, aAantalTracks, aDivision: integer);
    procedure Mf_TrackStart;
    procedure Mf_TrackEnd;
    procedure Mf_SeqNum(N: integer);
    procedure Mf_Eot;
    procedure Mf_Text(Soort: integer; S: AnsiString);
    procedure Mf_Tempo(T: LongInt);
    procedure Mf_smpte(S: AnsiString);
    procedure Mf_TimeSig(P1, P2, P3, P4: integer);
    procedure Mf_KeySig(Aantal: integer; Mineur: boolean);
    procedure Mf_SeqSpecific(M: AnsiString);
    procedure Mf_MetaMisc(Soort: integer; M: AnsiString);
    procedure Mf_SysEx(S: AnsiString);
    procedure Mf_Arbitrary(S: AnsiString);
    function CurTime: TTijd; { rekent om naar 64-sten }
    function Division: Word;
    procedure MsgInit;
    function Msg: AnsiString;
    procedure MsgAdd(C: Byte);
  public
    constructor Create(aMidiObject: TMidiObject; const ALogFileName: String = '');
    function Lees(const aFileName: String): boolean;
  end;

implementation
uses
  SysUtils,
  {$ifndef fpc}
  AnsiStrings,
  {$endif}
  cmpMidiEvent;

type
  TCharArray = array[0..10000] of AnsiChar;
  PCharArray = ^TCharArray;

procedure TMidiLezer.Log(const S: String);
begin
  if FUseLogfile then
    writeln(LogFile, S);
end;

procedure TMidiLezer.Mf_Header(aFormaat, aAantalTracks, aDivision: integer);
begin
   FMidiObject.Division := aDivision;
   FMidiObject.Formaat := aFormaat;
end;

procedure TMidiLezer.Mf_TrackStart;
begin
  FTrack := TMidiTrack.Create(Format('<Zonder naam %d>', [FMidiObject.Tracks.Count]));
  FMidiObject.Tracks.Add(FTrack);
  Mf_CurrTime := 0;
end;

procedure TMidiLezer.Mf_TrackEnd;
begin
end;

procedure TMidiLezer.Mf_SeqNum(N: integer);
begin
end;

procedure TMidiLezer.Mf_Eot;
begin
end;

procedure TMidiLezer.Mf_Text(Soort: integer; S: AnsiString);
begin
  FTrack.Teksten.Add(TTekstEvent.Create(CurTime, FMidiObject.Division,  Soort, S));
end;

procedure TMidiLezer.Mf_Tempo(T: LongInt);
begin
  FMidiObject.TempoChanges.Add(TTempoChangeEvent.Create(CurTime, FMidiObject.Division, T));
  //FMidiObject.TempoChanges.Add(TTempoChangeEvent.Create(CurTime, FMidiObject.Division, T div 6000));
end;

procedure TMidiLezer.Mf_smpte(S: AnsiString);
begin
end;

function TotDeMacht2(I: integer): integer;
var R: integer;
begin
  R := 2;
  TotDeMacht2 := R shl (I-1);
end;

procedure TMidiLezer.Mf_TimeSig(P1, P2, P3, P4: integer);
  function TotDeMacht2(I: integer): integer;
  var R: integer;
  begin
    R := 2;
    TotDeMacht2 := R shl (I-1);
  end;
begin
  FMidiObject.Maatsoorten.Add(TMaatsoortEvent.Create(CurTime, FMidiObject.Division, P1, TotDeMacht2(P2)));
end;

procedure TMidiLezer.Mf_KeySig(Aantal: integer; Mineur: boolean);
begin
  FMidiObject.Toonsoorten.Add(TToonsoortEvent.Create(CurTime, FMidiObject.Division, Aantal));
end;

procedure TMidiLezer.Mf_SeqSpecific(M: AnsiString);
begin
end;

procedure TMidiLezer.Mf_MetaMisc(Soort: integer; M: AnsiString);
begin
  case Soort of
    sequence_name: FTrack.Naam := UnicodeString(M);
  end;
end;

procedure TMidiLezer.Mf_SysEx(S: AnsiString);
begin
end;

procedure TMidiLezer.Mf_Arbitrary(S: AnsiString);
begin
end;

function TMidiLezer.CurTime: TTijd;
begin
  Result := mf_CurrTime;
end;

const
  Mf_NoMerge = false;

type
  ELeesMidi = class(Exception);

procedure Stop(S: String);
begin
  raise ELeesMidi.Create(S);
end;

function TMidiLezer.LeesSignature: AnsiString;
var N: integer; B: array[0..4] of AnsiChar;
begin
  B[4] := #0;
  N := 0; // fpc geeft anders een warning;
  BlockRead(F, B[0], 4, N);
  if N <> 4 then
    Result := ''
  else
  {$ifdef fpc}
    Result := StrPas(B);
  {$else}
    Result := AnsiStrings.StrPas(B);
  {$endif}
end;

function TMidiLezer.egetc: Byte;
var N: integer; B: Byte;
begin
  N := 0; // fpc geeft anders een warning;
  B := 0;
  BlockRead(F, B, 1, N);
  if N <> 1 then
    stop('Fout in egetc');
  Result := B;
  Dec(Mf_TobeRead);
end;


function TMidiLezer.ReadVariNum: LongInt;
var Value: LongInt; C: integer;
begin
  C := egetc;
  Value := C;
  if (C and $80) <> 0 then
  begin
    Value := Value and $7f;
    repeat
      c := egetc;
      Value := (Value shl 7) + c and $7f;
    until C and $80 = 0;
  end;
  Result := Value;
end;

function BytesTo32Bit(C1, C2, C3, C4: Byte): LongInt;
begin
  Result := C1;
  Result := (Result shl 8) + C2;
  Result := (Result shl 8) + C3;
  Result := (Result shl 8) + C4;
end;

function To16Bit(C1, C2: integer): Integer;
begin
  To16Bit := ((C1 and $ff) shl 8) + (C2 and $ff);
end;

function TMidiLezer.Read32Bit: LongInt;
var C1, C2, C3, C4: Byte;
begin
  C1 := egetc;
  C2 := egetc;
  C3 := egetc;
  C4 := egetc;
  Read32Bit := BytesTo32Bit(C1, C2, C3, C4);
end;


function TMidiLezer.Read16Bit: integer;
var B1, B2: Byte;
begin
  B1 := EGetc;
  B2 := EGetc;
  Read16Bit := To16Bit(B1, B2);
end;

procedure TMidiLezer.MsgInit;
begin
  FMsgBuffer := '';
  SetLength(FMsgBytes, 0);
end;

function TMidiLezer.Msg: AnsiString;
begin
  Msg := FMsgBuffer;
end;

procedure TMidiLezer.MsgAdd(C: Byte);
begin
  FMsgBuffer := FMsgBuffer + AnsiChar(C);
  SetLength(FMsgBytes, Length(FMsgBytes)+1);
  FMsgBytes[Length(FMsgBytes)-1] := C;
end;


procedure TMidiLezer.MetaEvent(Soort: integer);
var M: AnsiString;
begin
  M := Msg;
  case Soort of
    sequence_number: Mf_SeqNum(To16Bit(ord(M[1]), ord(M[2])));
    text_event..cue_point: Mf_Text(Soort, M);
    end_of_track: Mf_eot;
    set_tempo: Mf_Tempo(BytesTo32Bit(0, FMsgBytes[0], FMsgBytes[1], FMsgBytes[2]));
    smpte_offset: Mf_smpte(M);
    time_signature: Mf_TimeSig(ord(M[1]), ord(M[2]), ord(M[3]), ord(M[4]));
    key_signature: Mf_KeySig(ShortInt(ord(M[1])), M[2] <> #0);
    $7f: Mf_SeqSpecific(M);
    else Mf_MetaMisc(Soort, M);
  end;
  Log('Meta event '+IntToHex(Soort, 2)+ ' ' + UnicodeString(M));
end;

procedure TMidiLezer.ChanMessage(Status, C1, C2: integer);
var Chan: integer; E: TNootEvent;
begin
  Chan := Status and $f;
  Status := Status and $F0;
  case Status of
    note_off, note_on:
    begin
      if (Status = note_off)
      or (C2 = 0) then{ velocity }
        E := TNootEvent.Create(CurTime, Division, Chan+1, C1, 0, false) { note off }
      else
        E := TNootEvent.Create(CurTime, Division, Chan+1, C1, C2, true);  { note on }
      FTrack.AddEvent(E);
    end;
    poly_aftertouch, control_change, program_chng, channel_aftertouch, pitch_wheel:
      FTrack.AddMidiOpdracht(TDataEvent.Create(Curtime, Division, Chan+1, Status , C1, C2));
  end;
  with FMidiObject do
    if CurTime > HoogsteMoment then
      HoogsteMoment := CurTime;
  Log('chan '+IntToHex(Chan, 2) + ', status ' + IntToHex(Status, 2) +
    ', data ' + IntToHex(C1, 2) + ' ' + IntToHex(C2, 2));
end;

procedure TMidiLezer.ReadHeader;
var Format, nTrks, myDivision: integer; S: AnsiString;
begin
  Log('**Lees header**');
  S := LeesSignature;
  if S = 'MThd' then
  begin
    Mf_toberead := read32bit;
    Format := read16bit;
    nTrks := read16bit;
    myDivision := read16bit;
    Mf_Header(Format, nTrks, myDivision);
    while Mf_Toberead > 0 do
      egetc; { de rest doorlopen }
    Log('format ' + IntToStr(Format) + ', Aantal tracks ' + IntToStr(nTrks) +
      ', division ' + IntToStr(myDivision));
  end;
  Log('**Einde lees header**');
end;

function TMidiLezer.ReadTrack: boolean;
const ChanType: array[0..15] of byte = (0,0,0,0,0,0,0,0,2,2,2,2,1,1,2,0);
var LookFor: LongInt; C, C1, Soort, Running,
    Status, Needed: integer; SysExContinue: boolean;
    myInt: Integer;
begin
  Log('***Start lees track***');
  SysExContinue := false;
  Running := 0;
  Status := 0;
  Mf_Toberead := read32bit;
  Mf_CurrTime := 0;
  Mf_TrackStart;
  while Mf_toberead > 0 do
  begin
    Inc(Mf_currtime, readvarinum); { delta time }
    C := egetc;
    if SysExContinue and (C <> $F7) then
      stop('vervolg van een sysex verwacht');
    if (C and $80) = 0 then
    begin
      if status = 0 then
        Stop('Onverwachte running status')
      else
        Running := 1;
    end
    else
    begin
      Status := C;
      Running := 0;
    end;
    Needed := ChanType[(Status shr 4) and $f];
    if Needed <> 0 then
    begin
      if running <> 0 then
        c1 := c
      else
        c1 := egetc;
      if Needed > 1 then
        ChanMessage(Status, c1, egetc)
      else
        ChanMessage(Status, c1, 0);
    end
    else
    begin
      case c of
        meta_event:
        begin
          Soort := egetc;
          myInt := readvarinum;  { fp heeft een andere evaluatie volgorde. readvarinum verlaagt Mf_Toberead }
          LookFor := Mf_Toberead - myInt;
//    ipv      LookFor := Mf_Toberead - readvarinum;
          MsgInit;
          while Mf_toberead > LookFor do
            MsgAdd(egetc);
          MetaEvent(Soort);
          if Soort = sequence_name then
            FTrack.Naam := String(Msg);
        end;
        $f0:
        begin
          myInt := readvarinum;  { fp heeft een andere evaluatie volgorde. readvarinum verlaagt Mf_Toberead }
          LookFor := Mf_Toberead - myInt;
          //LookFor := Mf_ToBeRead - ReadVarINum;
          MsgInit;
          MsgAdd($F0);
          while Mf_ToBeRead > LookFor do
          begin
            c := egetc;
            MsgAdd(C);
          end;
          if (c=$F7) or Mf_NoMerge then
            Mf_SysEx(Msg)
          else
            SysExContinue := true;
        end;
        $F7: { SysEx vervolg en andere dingen }
        begin
          myInt := readvarinum;  { fp heeft een andere evaluatie volgorde. readvarinum verlaagt Mf_Toberead }
          LookFor := Mf_Toberead - myInt;
          //LookFor := Mf_ToBeRead - ReadVarINum;
          if not SysExContinue then
            MsgInit;
          while Mf_ToBeRead > LookFor do
          begin
            C := egetc;
            MsgAdd(C);
          end;
          if not SysExContinue then
            Mf_Arbitrary(msg)
          else if C = $f7 then
          begin
            Mf_SysEx(Msg);
            SysExContinue := false;
          end;
        end;
        else
          Stop('onverwachte byte');
      end; { endcase }
   end { Needed <> 0 }
  end; { endwhile }
  Mf_TrackEnd;
  Result := true;
  Log('***Einde lees track***');
end;

constructor TMidiLezer.Create(aMidiObject: TMidiObject; const ALogFileName: String = '');
begin
  inherited Create;
  FMidiObject := aMidiObject;
  LogFileName := ALogFileName;
end;

function TMidiLezer.Lees(const aFileName: String): Boolean;
var
  PrevFileMode: integer;
  Sectie: AnsiString;
  B: PCharArray;
  AantalBytes,
  AantalGelezen: integer;
  myOK: boolean;
begin
  FMidiObject.Clear;
  myOK := true;
  AssignFile(F, aFileName);
  if LogFileName <> '' then
  begin
    FUseLogFile := true;
    AssignFile(LogFile, LogFileName);
    Rewrite(LogFile);
    writeln(LogFile, 'Start lezen ', aFileName);
  end
  else
    FUseLogFile := false;
  PrevFileMode := FileMode;
  FileMode := 0;
  Reset(F, 1);
  ReadHeader;
  Sectie := LeesSignature;
  while myOK
  and (Sectie <> '') do
  begin
    if Sectie = 'MTrk' then
      ReadTrack
    else if Sectie = 'CASM' then
//      LeesCASM
    else
    begin
//      S := 'Onbekende sectie: '+ Sectie + '. Doorgaan met lezen van de volgende sectie?';
//      OK := MessageDlg(S, mtWarning,
//        [mbYes, mbNo], 0) = mrYes;
      myOk := True;
      if myOK then
      begin
        AantalBytes := read32bit;
        GetMem(B, AantalBytes);
        AantalGelezen := 0; // fpc geeft anders een warning;
        BlockRead(F, B^, AantalBytes, AantalGelezen);
        FreeMem(B, AantalBytes);
      end;
    end;
    if myOK then
      Sectie := LeesSignature;
  end;
  CloseFile(F);
  if LogFileName <> '' then
  begin
    writeln(LogFile, 'Einde lezen ', aFileName);
    CloseFile(LogFile);
  end;
  FileMode := PrevFileMode;
  Result := myOK;
end;

function TMidiLezer.Division: Word;
begin
  Result := FMidiObject.Division;
end;

end.
