unit cmpMidiSchrijver;

interface
uses
  Classes,
  cmpMidiObject,
  cmpMidiBuffer;

type
  TMidiSchrijver = class(TObject)
  private
    FMidiObject: TMidiObject;
    FMidiBuffer: TMidiBuffer;
    procedure NewFile;
//    procedure MaakTempoTrack;
    procedure AddTrackName(const aValue: AnsiString);
    procedure ExportMidiEvents(aNootEvents: TMidiEvents);
  public
    FoutMelding: String;
    constructor Create(aMidiObject: TMidiObject);
    destructor Destroy; override;
    function Schrijf(const aFileName: String): boolean;
  end;


implementation
uses
  SysUtils,

  uTypes,
  uMidiConstants,
  cmpMidiEvent;

constructor TMidiSchrijver.Create(aMidiObject: TMidiObject);
begin
  inherited Create;
  FMidiObject := aMidiObject;
  FMidiBuffer := TMidiBuffer.Create;
end;

destructor TMidiSchrijver.Destroy;
begin
  FMidiBuffer.Free;
  inherited Destroy;
end;


function TMidiSchrijver.Schrijf(const aFileName: String): boolean;
var
  myTrackIndex: Integer;
  T: TMidiTrack;
begin
  NewFile;
//  MaakTempoTrack;

  for myTrackIndex := 0 to FMidiObject.Tracks.Count-1 do
  begin
    T := FMidiObject.Tracks[myTrackIndex];
    FMidiBuffer.NewTrack;
    AddTrackName(AnsiString(T.Naam));
    T.MaakSamengevoegdeEvents;
//    for myKanaalIndex := 1 to 16 do
//      ExportMidiEvents(T.Kanaal[myKanaalIndex].NootEvents);
    ExportMidiEvents(T.SamengevoegdeEvents);
    FMidiBuffer.EndTrack;
  end;
  try
    FMidiBuffer.SchrijfNaarFile(aFilename);
    Result := True;
  except
    on E: Exception do
    begin
      Foutmelding := E.Message;
      Result := False;
    end;
  end;
end;

procedure TMidiSchrijver.NewFile;
var
  L: LongInt;
begin
  FMidiBuffer.Reset;
  FMidiBuffer.WriteAnsiString(Mthd);
  L := 6;
  FMidiBuffer.WriteInt32(L);
  FMidiBuffer.WriteInt16(FMidiObject.Formaat);
  FMidiBuffer.WriteInt16(FMidiObject.Tracks.Count);
  FMidiBuffer.WriteInt16(FMidiObject.Division);
end;

//procedure TMidiSchrijver.MaakTempoTrack;
//var
//  I: Integer;
//  L: TMidiEventList;
//  E: TMidiEvent;
//  T: DWord;
//begin
//  FMidiBuffer.NewTrack;
//  AddTrackName('Tempo track');
//  { eerst mergen van toonsoorten, maatsoorten en tempowijzigingen }
//
//  L := TMidiEventList.Create;
//  try
//    L.OwnsObjects := False;
//    for I := 0 to FMidiObject.Maatsoorten.Count-1 do
//      L.Add(FMidiObject.Maatsoorten[I]);
//    for I := 0 to FMidiObject.Toonsoorten.Count-1 do
//      L.Add(FMidiObject.Toonsoorten[I]);
//    for I := 0 to FMidiObject.TempoChanges.Count-1 do
//      L.Add(FMidiObject.TempoChanges[I]);
//    L.Sort;
//    T := 0;
//    for I := 0 to L.Count-1 do
//    begin
//      E := L[I];
//      E.ExportNaarBuffer(E.Time-T, FMidiBuffer);
//      T := E.Time;
//    end;
//  finally
//    L.Free;
//  end;
//  (*
//  T := 0;
//
//  E := FMidiObject.Toonsoorten[0];
//  E.ExportNaarBuffer(E.Time-T, FMidiBuffer);
//  T := E.Time;
//
//  E := FMidiObject.Maatsoorten[0];
//  E.ExportNaarBuffer(E.Time-T, FMidiBuffer);
//  T := E.Time;
//
//  E := FMidiObject.TempoChanges[0];
//  E.ExportNaarBuffer(E.Time-T, FMidiBuffer);
//  T := E.Time;
//*)
//  FMidiBuffer.EndTrack;
//end;

procedure TMidiSchrijver.AddTrackName(const aValue: AnsiString);
//var
//  D: array[0..255] of AnsiChar;
//  myValue: AnsiString;
begin
//  myValue := aValue;
//  Move(myValue[1], D[0], Length(myValue));
//  FMidiBuffer.AddMetaEvent(0, sequence_name, D, Length(myValue));
  FMidiBuffer.AddMetaEvent(0, sequence_name, aValue);
end;

procedure TMidiSchrijver.ExportMidiEvents(aNootEvents: TMidiEvents);
var
  I: integer;
  E: TMidiEvent;
  T: TTijd;
  Gelijk: boolean;
begin
  I := 0;
  T := 0;
  while I <= aNootEvents.Count-1 do
  begin
    E := aNootEvents[I];
    E.ExportNaarBuffer(E.Time-T, FMidiBuffer);
    T := E.Time;
    { verwerk gelijktijdige events }
    Inc(I);
    Gelijk := true;
    while Gelijk
    and (I <= aNootEvents.Count-1) do
    begin
      E := aNootEvents[I];
      if E.Time = T then
      begin
        E.ExportNaarBuffer(0, FMidiBuffer);
        Inc(I);
      end
      else
        Gelijk := false;
    end;
  end;
end;

end.
