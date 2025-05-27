unit cmpMidiObject;

interface
uses
  Classes,
  Generics.Collections,
  uTypes,
  uMidiConstants,
  cmpMidiEvent;

type
  TMidiEvents = TObjectList<TMidiEvent>;
  TKanaalEvents = TObjectList<TKanaalEvent>;
  TTekstEvents = TObjectList<TTekstEvent>;

  TMidiKanaal = class(TObject)
  private
    FMidiOpdrachten: TDataEventList;
    FNootEvents: TKanaalEvents;
  public
    constructor Create;
    destructor Destroy; override;
    property MidiOpdrachten: TDataEventList read FMidiOpdrachten;
    property NootEvents: TKanaalEvents read FNootEvents;
  end;

  TMidiTrack = class(TObject)
  public
    Kanaal: array[1..midiMaxKanalen] of TMidiKanaal;
    Naam: String;
    Teksten: TTekstEvents;
    SamengevoegdeEvents: TMidiEvents;
    constructor Create(aNaam: String);
    destructor Destroy; override;
    procedure AddEvent(E: TKanaalEvent);
    procedure AddMidiOpdracht(E: TDataEvent);
    procedure MaakSamengevoegdeEvents;
  end;

  TTracks = TObjectList<TMidiTrack>;

  TMidiObject = class(TObject)
  public
    Tracks: TTracks;
    Division: integer;
    Formaat: integer; { 0, 1 of 2 }
    Maatsoorten: TMidiEventList;
    Toonsoorten: TMidiEventList;
    TempoChanges: TMidiEventList;
    HoogsteMoment: TMoment;
    constructor Create;
    destructor Destroy; override;
    procedure BepaalHoogsteMoment;
    function GetTrack(I: integer): TMidiTrack;
    function NewTrack(aNaam: String): TMidiTrack;
    procedure Clear;
  end;

implementation
uses
  Generics.Defaults;

constructor TMidiKanaal.Create;
begin
  inherited Create;
  FNootEvents := TKanaalEvents.Create;
  FMidiOpdrachten := TDataEventList.Create;
end;

destructor TMidiKanaal.Destroy;
begin
  FNootEvents.Free;
  FMidiOpdrachten.Free;
  inherited Destroy;
end;

constructor TMidiTrack.Create(aNaam: String);
var I: integer;
begin
  inherited Create;
  Naam := aNaam;
  for I := 1 to midiMaxKanalen do
    Kanaal[I] := TMidiKanaal.Create;
  Teksten := TTekstEvents.Create;
  SamengevoegdeEvents := TMidiEvents.Create(False);
end;

destructor TMidiTrack.Destroy;
var I: integer;
begin
  for I := 1 to midiMaxKanalen do
    Kanaal[I].Free;
  Teksten.Free;
  SamengevoegdeEvents.Free;
  inherited Destroy;
end;

procedure TMidiTrack.AddEvent(E: TKanaalEvent);
begin
  Kanaal[E.Kanaal].NootEvents.Add(E);
end;

procedure TMidiTrack.AddMidiOpdracht(E: TDataEvent);
begin
  Kanaal[E.Kanaal].MidiOpdrachten.Add(E);
end;

type
  TMyKanaalEventComparer = class(TComparer<TMidiEvent>)
  public
    {$ifdef fpc}
    function Compare(constref aLeft, aRight: TMidiEvent): Integer; override;
    {$else}
    function Compare(const aLeft, aRight: TMidiEvent): Integer; override;
    {$endif}
  end;

{$ifdef fpc}
function TMyKanaalEventComparer.Compare(constref aLeft, aRight: TMidiEvent): Integer;
{$else}
function TMyKanaalEventComparer.Compare(const aLeft, aRight: TMidiEvent): Integer;
{$endif}
begin
  Result := aLeft.CompareWith(aRight)
end;

procedure TMidiTrack.MaakSamengevoegdeEvents;
var
  I: Integer;
  myEvent: TMidiEvent;
  myComparer: TMyKanaalEventComparer;
begin
  myComparer := TMyKanaalEventComparer.Create;
  try
    SamengevoegdeEvents.Clear;
    for I := 1 to midiMaxKanalen do
    begin
      for myEvent in Kanaal[I].NootEvents do
        SamengevoegdeEvents.Add(myEvent);
      for myEvent in Kanaal[I].MidiOpdrachten do
        SamengevoegdeEvents.Add(myEvent);
    end;
    SamengevoegdeEvents.Sort(myComparer);
  finally
    myComparer.Free;
  end;
end;

constructor TMidiObject.Create;
begin
  inherited Create;
  Tracks := TTracks.Create;
  Maatsoorten := TMidiEventList.Create;
  Toonsoorten := TMidiEventList.Create;
  TempoChanges := TMidiEventList.Create;
end;

destructor TMidiObject.Destroy;
begin
  Tracks.Free;
  Maatsoorten.Free;
  Toonsoorten.Free;
  TempoChanges.Free;
  inherited Destroy;
end;

procedure TMidiObject.BepaalHoogsteMoment;
var T: TMidiTrack; I, J, K: integer; H, M: TMidiEvent;
begin
  H := nil;
  for I := 0 to Tracks.Count-1 do
  begin
    T := Tracks[I];
    for J := 1 to midiMaxKanalen do
    begin
      for K := 0 to T.Kanaal[J].NootEvents.Count-1 do
      begin
        M := T.Kanaal[J].NootEvents[K];
        if (H=nil)
        or (M.Time > H.Time) then
          H := M;
      end;
    end;
  end;
  if Assigned(H) then
    HoogsteMoment := H.Time
end;

function TMidiObject.GetTrack;
begin
  Result := Tracks[I];
end;

function TMidiObject.NewTrack(aNaam: String): TMidiTrack;
begin
  Result := TMidiTrack.Create(aNaam);
  Tracks.Add(Result);
end;


procedure TMidiObject.Clear;
begin
  Tracks.Clear;
  Division := 0;
  Formaat := 0;
  Maatsoorten.Clear;
  Toonsoorten.Clear;
  TempoChanges.Clear;
end;

end.
