unit cmpAfspeelLijst;
{$ifdef fpc}
{$mode DelphiUnicode}
{$endif}

interface

uses
  Classes, SysUtils,
  Generics.Collections,
  Generics.Defaults,

  { MidiEditor }
  uTypes,
  cmpAfspeelEvent,
  cmpTrackElement;

type
  TAfspeelEventComparer = class(TComparer<TAfspeelEvent>)
  public
    {$ifdef fpc}
    function Compare(constref aLeft, aRight: TAfspeelEvent): Integer; override;
    {$else}
    function Compare(const aLeft, aRight: TAfspeelEvent): Integer; override;
    {$endif}
  end;

  TAfspeelEvents = TList<TAfspeelEvent>;

  TAfspeelLijst = class(TObject)
  private
    FAfspeelEvents: TAfspeelEvents;
    FComparer: TAfspeelEventComparer;
    function GetAfspeelEvent(aTijd: TTijd; aMoment: TMoment): TAfspeelEvent; // creeert hem als deze niet bestaat
  public
    constructor Create;
    destructor Destroy; override;
    procedure StartMaakLijst;
    procedure EindeMaakLijst;
    procedure ToevoegenNootAan(aTijd: TTijd; aMoment: TMoment; aKanaal, aHoogte, aVelocity: byte);
    procedure ToevoegenNootUit(aTijd: TTijd; aMoment: TMoment; aKanaal, aHoogte: byte);
    procedure ToevoegenControlChangeElement(aTijd: TTijd; aMoment: TMoment; aKanaal: Byte; aSoort: TSoortDataElement; aData: byte);
    procedure ToevoegenProgramChangeElement(aTijd: TTijd; aMoment: TMoment; aKanaal: Byte; aInstrument: byte);
    function FindAfspeelEvent(aTijd: TTijd): TAfspeelEvent;
    property AfspeelEvents: TAfspeelEvents read FAfspeelEvents;
  end;

implementation
uses
  uMidiConstants;

{$ifdef fpc}
function TAfspeelEventComparer.Compare(constref aLeft, aRight: TAfspeelEvent): Integer;
{$else}
function TAfspeelEventComparer.Compare(const aLeft, aRight: TAfspeelEvent): Integer;
{$endif}
begin
  Result := aLeft.CompareWith(aRight)
end;


{ TAfspeelLijst }
constructor TAfspeelLijst.Create;
begin
  inherited Create;
  FComparer := TAfspeelEventComparer.Create;
  FAfspeelEvents := TObjectList<TAfspeelEvent>.Create(FComparer);
end;

destructor TAfspeelLijst.Destroy;
begin
  FAfspeelEvents.Free;
  //FComparer.Free; wordt in TAfspeelEvent destroy gedaan
  inherited Destroy
end;

procedure TAfspeelLijst.StartMaakLijst;
begin
  FAfspeelEvents.Clear;
end;

procedure TAfspeelLijst.EindeMaakLijst;
begin
  FAfspeelEvents.Sort(FComparer); // niet nodig
end;


function TAfspeelLijst.GetAfspeelEvent(aTijd: TTijd; aMoment: TMoment): TAfspeelEvent;
begin
  Result := FindAfspeelEvent(aTijd);
  if Result = nil then
  begin
    Result := TAfspeelEvent.Create(aTijd, aMoment);
    FAfspeelEvents.Add(Result);
  end;
end;

function TAfspeelLijst.FindAfspeelEvent(aTijd: TTijd): TAfspeelEvent;
var
  myEvent: TAfspeelEvent;
  myIndex: Int64;
  //B: Boolean;
begin
  myEvent := TAfspeelEvent.Create(aTijd, 0);
  try
    //B := FAfspeelEvents.BinarySearch(myEvent, myIndex, FComparer);
    myIndex := FAfspeelEvents.IndexOf(myEvent);
    if myIndex < 0 then
    //if not B then
      Result := nil
    else
      Result := FAfspeelEvents[myIndex];
  finally
    myEvent.Free;
  end;
end;

procedure TAfspeelLijst.ToevoegenNootAan(aTijd: TTijd; aMoment: TMoment; aKanaal, aHoogte, aVelocity: byte);
var
  myEvent: TAfspeelEvent;
begin
  myEvent := GetAfspeelEvent(aTijd, aMoment);
  myEvent.AddNootAan(aKanaal, aHoogte, aVelocity);
end;

procedure TAfspeelLijst.ToevoegenNootUit(aTijd: TTijd; aMoment: TMoment; aKanaal, aHoogte: byte);
var
  myEvent: TAfspeelEvent;
begin
  myEvent := GetAfspeelEvent(aTijd, aMoment);
  myEvent.AddNootUit(aKanaal, aHoogte);
end;

procedure TAfspeelLijst.ToevoegenControlChangeElement(aTijd: TTijd; aMoment: TMoment; aKanaal: Byte; aSoort: TSoortDataElement; aData: byte);
var
  myEvent: TAfspeelEvent;
  myControlNr: Byte;
begin
  case aSoort of
    sdeVolume: myControlNr := midictrl_volume;
    sdePanorama: myControlNr := midictrl_pan;
    sdePedaal: myControlNr := midictrl_damper_pedal;
    else
      myControlNr := 0; // komt als het goed is niet voor
  end;
  myEvent := GetAfspeelEvent(aTijd, aMoment);
  myEvent.AddControlChangeEvent(aKanaal, myControlNr, aData);
end;

procedure TAfspeelLijst.ToevoegenProgramChangeElement(aTijd: TTijd; aMoment: TMoment; aKanaal: Byte; aInstrument: byte);
var
  myEvent: TAfspeelEvent;
begin
  myEvent := GetAfspeelEvent(aTijd, aMoment);
  myEvent.AddProgramChangeEvent(aKanaal, aInstrument);
end;

end.

