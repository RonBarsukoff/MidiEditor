unit cmpMidiEvent;
{$ifdef fpc}
{$mode DelphiUnicode}
{$endif}

interface
uses
  uTypes,
  Generics.Collections,
  Generics.Defaults,
  uMidiConstants,
  cmpMidiBuffer;

type
  TMidiEvent = class(TObject)
  public
    Time: TTijd;
    Division: Word;
    constructor Create(aTime: TTijd; aDivision: Word);
    procedure ExportNaarBuffer(aDeltaTime: TTijd; aMidiBuffer: TMidiBuffer); virtual; abstract;
    function CompareWith(E: TMidiEvent): integer; { -1, 0, 1 } virtual;
    function Tekst: String; virtual;
  end;

  TKanaalEvent = class(TMidiEvent)
    Kanaal: byte;
  end;

  TNootEvent = class(TKanaalEvent)
  public
    NoteOn: boolean;
    Hoogte: byte;
    Velocity: byte;
    constructor Create(aTime: TTijd; aDivision: Integer; aKanaal, aHoogte, aVelocity: byte; aOn: boolean);
    function CompareWith(E: TMidiEvent): integer; override;
    procedure ExportNaarBuffer(aDeltaTime: TTijd; aMidiBuffer: TMidiBuffer); override;
    function Tekst: String; override;
  end;

  TToonsoortEvent = class(TMidiEvent)
    AantalKruisen: integer;
    constructor Create(T: TTijd; aDivision: Integer; A: integer);
    procedure ExportNaarBuffer(aDeltaTime: TTijd; aMidiBuffer: TMidiBuffer); override;
    function Tekst: String; override;
  end;

  TMaatsoortEvent = class(TMidiEvent)
    Teller: integer;
    Noemer: integer;
    constructor Create(T: TTijd; aDivision: Integer; DeTeller, DeNoemer: integer);
    procedure ExportNaarBuffer(aDeltaTime: TTijd; aMidiBuffer: TMidiBuffer); override;
    function Tekst: String; override;
  end;

(*
  TProgramChangeEvent = class(TKanaalEvent)
  public
    Instrument: byte;
    constructor Create(T: LongInt; K, I: byte);
    procedure ExportNaarMidiFile(T: LongInt; MidiHandle: word); override;
    procedure ToevoegenAanPlayer; override;
  end;
*)
  TDataEvent = class(TKanaalEvent) { wordt gebruikt voor alle andere events }
  public
    Status,
    Data1,
    Data2: byte;
    constructor Create(T: TTijd; aDivision: Integer; K, EenStatus, EenData1, EenData2: byte);
    procedure ExportNaarBuffer(aDeltaTime: TTijd; aMidiBuffer: TMidiBuffer); override;
    function Tekst: String; override;
  end;

  TTempoChangeEvent = class(TMidiEvent)
  public
    Tempo: integer;
    constructor Create(T: TTijd; aDivision: Integer; aTempo: integer);
    procedure ExportNaarBuffer(aDeltaTime: TTijd; aMidiBuffer: TMidiBuffer); override;
    function Tekst: String; override;
  end;

  TTekstEvent = class(TMidiEvent)
    FSoort: integer;
    FTekst: AnsiString;
  public
    constructor Create(T: TTijd; aDivision: Integer; aSoort: integer; const aTekst: AnsiString);
    procedure ExportNaarBuffer(aDeltaTime: TTijd; aMidiBuffer: TMidiBuffer); override;
    function Tekst: String; override;
  end;

  TMidiEventList = class(TObjectList<TMidiEvent>)
    constructor Create;
  end;

  TDataEventList = class(TObjectList<TDataEvent>)
    constructor Create;
  end;

implementation
uses
  SysUtils,

  uProcs;

const
  Tab = #9;

  { TMidiEvent }
constructor TMidiEvent.Create(aTime: TTijd; aDivision: Word);
begin
  inherited Create;
  Time := aTime;
  Division := aDivision;
end;

function TMidiEvent.CompareWith(E: TMidiEvent): integer;
begin
  if Time < E.Time then
    Result := -1
  else if Time = E.Time then
    Result := 0
  else
    Result := 1;
end;

function TMidiEvent.Tekst;
begin
  Result := 'MidiEvent '+ ClassName;
end;

{ TNootEvent }
function TNootEvent.Tekst;
begin
  Result := MomentNaarStr(Time, Division) +Tab;
  if NoteOn then
    Result := Result + 'on'
  else
    Result := Result + 'off';
  Result := Result + Tab + ToonhoogteAlsTekst(Hoogte);
  if NoteOn then
    Result := Result + Tab + IntTostr(Velocity);
end;

constructor TNootEvent.Create(aTime: TTijd; aDivision: Integer; aKanaal, aHoogte, aVelocity: byte; aOn: boolean);
begin
  inherited Create(aTime, aDivision);
  NoteOn := aOn;
  Hoogte := aHoogte;
  Velocity := aVelocity;
  if  aVelocity = 0 then
    NoteOn := false; { sommige keyboards geven geen note_off maar een velocity van 0 }
  Kanaal := aKanaal;
end;

procedure TNootEvent.ExportNaarBuffer(aDeltaTime: TTijd; aMidiBuffer: TMidiBuffer);
begin
  if NoteOn then
    aMidiBuffer.Add2ByteEvent(aDeltaTime, note_on, Kanaal-1, Hoogte, Velocity)
  else
    aMidiBuffer.Add2ByteEvent(aDeltaTime, note_off, Kanaal-1, Hoogte, Velocity);
end;

function TNootEvent.CompareWith(E: TMidiEvent): integer;
var B: boolean;
begin
  Result := inherited CompareWith(E);
  if Result = 0 then
  begin
    if E is TNootEvent then
    begin
      B := (E as TNootEvent).NoteOn;
      { noteoff is kleiner dan noteon }
      if (not NoteOn) and B then
        Result := -1
      else if NoteOn and not B then
        Result := 1;
    end
    else
      Result := 1; { TNootEvent komt na alle andere events }
  end;
end;

{ TToonsoortEvent }
constructor TToonsoortEvent.Create(T: TTijd; aDivision: Integer; A: integer);
begin
  inherited Create(T, aDivision);
  AantalKruisen := A;
end;

procedure TToonsoortEvent.ExportNaarBuffer(aDeltaTime: TTijd; aMidiBuffer: TMidiBuffer);
begin
  aMidiBuffer.AddKeySignature(aDeltaTime, AantalKruisen, true);
end;

function TToonsoortEvent.Tekst;
begin
  if AantalKruisen = 1 then
    Result := '1 kruis'
  else if AantalKruisen = -1 then
    Result := '1 mol'
  else if AantalKruisen >= 0 then
    Result := Format('%d kruisen', [AantalKruisen])
  else
    Result := Format('%d mollen', [-AantalKruisen]);
end;

{ TMaatsoortEvent }
constructor TMaatsoortEvent.Create(T: TTijd; aDivision: Integer; DeTeller, DeNoemer: integer);
begin
  inherited Create(T, aDivision);
  Teller := DeTeller;
  Noemer := DeNoemer;
end;

procedure TMaatsoortEvent.ExportNaarBuffer(aDeltaTime: TTijd; aMidiBuffer: TMidiBuffer);
begin
  aMidiBuffer.AddTimeSignature(aDeltaTime, Teller, Noemer);
end;

function TMaatsoortEvent.Tekst;
begin
  Result := Format('%d/%d', [Teller, Noemer]);
end;

{ TDataEvent }
constructor TDataEvent.Create(T: TTijd; aDivision: Integer; K, EenStatus, EenData1, EenData2: byte);
begin
  inherited Create(T, aDivision);
  Kanaal := K;
  Status := EenStatus;
  Data1 := EenData1;
  Data2 := EenData2;
end;

procedure TDataEvent.ExportNaarBuffer(aDeltaTime: TTijd; aMidiBuffer: TMidiBuffer);
begin
  if Status in [program_chng, channel_aftertouch] then
    aMidiBuffer.Add1ByteEvent(aDeltaTime, Status, Kanaal-1, Data1)
  else
    aMidiBuffer.Add2ByteEvent(aDeltaTime, Status, Kanaal-1, Data1, Data2);
end;

function TDataEvent.Tekst;
begin
  Result := MomentNaarStr(Time, Division) + Tab + MidiStatusTekst(Status);
  case Status of
    program_chng:
      Result := Result + Tab + MidiInstrumentNaam[Data1];
    control_change:
      Result := Result + Tab + MidiControlTekst(Data1, Data2, Tab);
    else
      Result := Result + Tab + Format('%d %d', [Data1, Data2]);
  end;
end;

constructor TTempoChangeEvent.Create(T: TTijd; aDivision: Integer; aTempo: integer);
begin
  inherited Create(T, aDivision);
  Tempo := aTempo;
end;

procedure TTempoChangeEvent.ExportNaarBuffer(aDeltaTime: TTijd; aMidiBuffer: TMidiBuffer);
begin
  aMidiBuffer.AddTempo(aDeltaTime, 1000000*60 div Tempo);
end;

function TTempoChangeEvent.Tekst;
begin
  Result := Format('%d tikken per minuut', [60*1000000 div Tempo]);
end;

constructor TTekstEvent.Create(T: TTijd; aDivision: Integer; aSoort: integer; const aTekst: AnsiString);
begin
  inherited Create(T, aDivision);
  FTekst := aTekst;
  FSoort := aSoort;
end;

procedure TTekstEvent.ExportNaarBuffer(aDeltaTime: TTijd; aMidiBuffer: TMidiBuffer);
begin
  aMidiBuffer.AddMetaEvent(aDeltaTime, FSoort, FTekst);
end;

function TTekstEvent.Tekst;
begin
  Result := IntToStr(Time)+Tab+IntToStr(FSoort)+Tab+String(FTekst);
end;

{$ifdef fpc}
function Comparision(constref aLeft, aRight: TMidiEvent): Integer;
{$else}
function Comparision(const aLeft, aRight: TMidiEvent): Integer;
{$endif}
begin
  Result := aLeft.CompareWith(aRight);
end;

{$ifdef fpc}
function CompareDataEvent(constref aLeft, aRight: TDataEvent): Integer;
{$else}
function CompareDataEvent(const aLeft, aRight: TDataEvent): Integer;
{$endif}
begin
  Result := aLeft.CompareWith(aRight);
end;

constructor TMidiEventList.Create;
begin
  inherited Create(TComparer<TMidiEvent>.Construct(Comparision));
end;

constructor TDataEventList.Create;
begin
  inherited Create(TComparer<TDataEvent>.Construct(CompareDataEvent));
end;


end.
