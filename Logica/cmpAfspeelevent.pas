unit cmpAfspeelEvent;

interface

uses
  Classes, SysUtils,
  Generics.Collections,
  uTypes;

type
  TSoortAfspeelEvent = (saeTempo, saeProgramChange, saeNootAan, saeNootUit,
    saeVolume, saePan, saePedaal, saeOverig);



  TAfspeelEventDetail = class(TObject)
  public
    function Prioriteit: integer; virtual; abstract;
    function Soort: TSoortAfspeelEvent; virtual; abstract;
    function CompareWith(aEvent: TAfspeelEventDetail): Integer;
    function Param: LongInt; virtual; abstract; { geschikt voor midiOutShortMsg }
  end;

   TAfspeelEventDetailLijst = TObjectList<TAfspeelEventDetail>;

  TAfspeelEvent = class(TObject)
  private
    FMoment: TMoment;
    FTijd: TTijd;
    FEvents: TAfspeelEventDetailLijst;
  public
    constructor Create(aTijd: TTijd; aMoment: TMoment);
    destructor Destroy; override;
    function CompareWith(aAfspeelEvent: TAfspeelEvent): Integer;
    procedure AddNootAan(aKanaal, aHoogte, aVelocity: byte);
    procedure AddNootUit(aKanaal, aHoogte: byte);
    procedure AddControlChangeEvent(aKanaal, aSoort, aData: byte);
    procedure AddProgramChangeEvent(aKanaal, aInstrument: byte);
    property Events: TAfspeelEventDetailLijst read FEvents;
    property Tijd: TTijd read FTijd;
    property Moment: TMoment read FMoment;
  end;

  TAfspeelEventList = class(TObjectList<TAfspeelEvent>);

  TKanaalAfspeelEvent = class(TAfspeelEventDetail)
  private
    FSoort, // note_on enz...
    FData1,
    FData2,
    FKanaal: byte;
  public
    constructor CreateNootAan(aKanaal, aHoogte, aVelocity: byte);
    constructor CreateNootUit(aKanaal, aHoogte: byte);
    //constructor CreateProgramChange(K, Instrument: byte);
    constructor CreateDataEvent(aKanaal, aSoort, aData1, aData2: byte);
    function Param: LongInt; override; { geschikt voor midiOutShortMsg }
    function Prioriteit: integer; override;
    function Hoogte: byte; { alleen geldig bij saeNootAan en saeNootUit }
    function Soort: TSoortAfspeelEvent; override;
    property Kanaal: byte read FKanaal;
  end;

  TTempoEvent = class(TAfspeelEventDetail)
  public
    Tempo: integer;
    constructor Create(T, EenTempo: integer);
    function Prioriteit: integer; override;
    function Soort: TSoortAfspeelEvent; override;
  end;

implementation
uses
  Generics.Defaults,
  Math,

  uMidiConstants;

type

  TAfspeelEventDetailComparer = class(TComparer<TAfspeelEventDetail>)
  public
    {$ifdef fpc}
    function Compare(constref aLeft, aRight: TAfspeelEventDetail): Integer; override;
    {$else}
    function Compare(const aLeft, aRight: TAfspeelEventDetail): Integer; override;
    {$endif}
  end;

  TAfspeelEventDetailList = class(TObjectList<TAfspeelEventDetail>)
  public
  end;


  {$ifdef fpc}
function TAfspeelEventDetailComparer.Compare(constref aLeft, aRight: TAfspeelEventDetail): Integer;
{$else}
function TAfspeelEventDetailComparer.Compare(const aLeft, aRight: TAfspeelEventDetail): Integer;
{$endif}
begin
  Result := aLeft.CompareWith(aRight)
end;

function TAfspeelEventDetail.CompareWith(aEvent: TAfspeelEventDetail): Integer;
begin
  if Prioriteit > aEvent.Prioriteit then
    Result := -1
  else if Prioriteit = aEvent.Prioriteit then
    Result := 0
  else
    Result := 1;
end;

constructor TAfspeelEvent.Create(aTijd: TTijd; aMoment: TMoment);
begin
  inherited Create;
  FTijd := aTijd;
  FMoment := aMoment;
  FEvents := TAfspeelEventDetailList.Create(TAfspeelEventDetailComparer.Create);
end;

destructor TAfspeelEvent.Destroy;
begin
  FEvents.Free;
  inherited Destroy;
end;

function TAfspeelEvent.CompareWith(aAfspeelEvent: TAfspeelEvent): Integer;
begin
  Result := CompareValue(FTijd, aAfspeelEvent.FTijd);
end;

procedure TAfspeelEvent.AddNootAan(aKanaal, aHoogte, aVelocity: byte);
begin
  FEvents.Add(TKanaalAfspeelEvent.CreateNootAan(aKanaal, aHoogte, aVelocity));
  FEvents.Sort;
end;

procedure TAfspeelEvent.AddNootUit(aKanaal, aHoogte: byte);
begin
  FEvents.Add(TKanaalAfspeelEvent.CreateNootUit(aKanaal, aHoogte));
  FEvents.Sort;
end;

procedure TAfspeelEvent.AddControlChangeEvent(aKanaal, aSoort, aData: byte);
begin
  FEvents.Add(TKanaalAfspeelEvent.CreateDataEvent(aKanaal, control_change, aSoort, aData));
  FEvents.Sort;
end;

procedure TAfspeelEvent.AddProgramChangeEvent(aKanaal, aInstrument: byte);
begin
  FEvents.Add(TKanaalAfspeelEvent.CreateDataEvent(aKanaal, program_chng, aInstrument, 0));
  FEvents.Sort;
end;

{ TKanaalAfspeelEvent }
constructor TKanaalAfspeelEvent.CreateNootAan(aKanaal, aHoogte, aVelocity: byte);
begin
  if aVelocity > 0 then
    CreateDataEvent(aKanaal, note_on, aHoogte, aVelocity)
  else
    CreateDataEvent(aKanaal, note_off, aHoogte, 0);
end;

constructor TKanaalAfspeelEvent.CreateNootUit(aKanaal, aHoogte: byte);
begin
  CreateDataEvent(aKanaal, note_off, aHoogte, 0);
end;

constructor TKanaalAfspeelEvent.CreateDataEvent(aKanaal, aSoort, aData1, aData2: byte);
begin
  inherited Create;
  FKanaal := aKanaal;
  FData1 := aData1;
  FData2 := aData2;
  FSoort := aSoort;
end;

function TKanaalAfspeelEvent.Param: LongInt;
type
  TMidiMsg = record RStatus, RData1, RData2, Dummy: Byte end;
begin
  with TMidiMsg(Result) do
  begin
    Dummy := 0;
    RData1 := FData1;
    RData2 := FData2;
    RStatus := FSoort or (FKanaal-1);
  end;
end;

function TKanaalAfspeelEvent.Prioriteit;
begin
  if Soort = saeNootAan then
    Result := 0
  else if Soort = saeProgramChange then
    Result := 9
  else if Soort = saePedaal then
    Result := 8
  else
    Result := 1;
end;

function TKanaalAfspeelEvent.Hoogte;
begin
  Result := FData1;
end;

function TKanaalAfspeelEvent.Soort;
begin
  case FSoort of
    program_chng:
      Result := saeProgramChange;
    note_on:
      Result := saeNootAan;
    note_off:
      Result := saeNootUit;
    control_change:
    begin
      case FData1 of
        midictrl_volume:
          Result := saeVolume;
        midictrl_pan:
          Result := saePan;
        midictrl_damper_pedal:
          Result := saePedaal
        else
          Result := saeOverig;
      end;
    end;
    else
      Result := saeOverig;
  end;
end;

constructor TTempoEvent.Create;
begin
  inherited Create;
  Tempo := EenTempo;
end;

function TTempoEvent.Prioriteit;
begin
  Result := 2;
end;

function TTempoEvent.Soort;
begin
  Result := saeTempo;
end;

end.

