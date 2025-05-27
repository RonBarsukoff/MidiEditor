unit cmpToonAfspeler;

interface
uses
  Classes,
  uCommonTypes;

type

  TToonAfspeler = class(TObject)
  private
    FZetToonUit: Boolean;
    FNieuweAfspeelToon: TAfspeelToon;
    FThread: TThread;
    FOk: Boolean;
    FMelding: String;
    function handleGetToon(var aAfspeelToon: TAfspeelToon): Boolean;
    function handleAskStopToon: Boolean;
    procedure handleUpdateStatus(aOk: Boolean; const aMelding: String);
  public
    OnStatusUpdate: TUpdateStatusEvent;
    constructor Create;
    destructor Destroy; override;
    procedure StartToon(aKanaal, aHoogte, aVelocity, aLengte: Integer);
    procedure StopToon;
    procedure Init(const aMidiOutDeviceName: String);
    procedure Done;
    property Melding: String read FMelding;
    property OK: Boolean read FOk;
  end;

implementation
uses
  SysUtils,
  cmpAfspeelThread;

{ TToonAfspeler }
constructor TToonAfspeler.Create;
begin
  inherited Create;
end;

destructor TToonAfspeler.Destroy;
begin
  FThread.Free;
  inherited Destroy;
end;

procedure TToonAfspeler.Init(const aMidiOutDeviceName: String);
var
  myThread: TAfspeelThread;
begin
  if Assigned(FThread) then
    Done;
  myThread := TAfspeelThread.Create(aMidiOutDeviceName);
  myThread.OnGetToon := handleGetToon;
  myThread.OnAskStopToon := handleAskStopToon;
  myThread.OnUpdateStatus := handleUpdateStatus;
  FThread := myThread;
  FThread.Start;
  SysUtils.Sleep(1000); // het lijkt wel of de midiuit handle enige tijd nodig heeft
end;

procedure TToonAfspeler.Done;
begin
  if Assigned(FThread) then
  begin
    FThread.Terminate;
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
end;

procedure TToonAfspeler.StartToon(aKanaal, aHoogte, aVelocity, aLengte: Integer);
begin
  with FNieuweAfspeelToon do
  begin
    Kanaal := aKanaal;
    Hoogte := aHoogte;
    Velocity := aVelocity;
    Lengte := aLengte;
    Aan := True;
  end;
end;

procedure TToonAfspeler.StopToon;
begin
  FZetToonUit := True;
end;

function TToonAfspeler.handleGetToon(var aAfspeelToon: TAfspeelToon): Boolean;
begin
  Result := FNieuweAfspeelToon.Aan;
  if Result then
  begin
    aAfspeelToon := FNieuweAfspeelToon;
    FNieuweAfspeelToon.Aan := False;
  end;
end;

function TToonAfspeler.handleAskStopToon: Boolean;
begin
  Result := FZetToonUit;
  FZetToonUit := False;
end;

procedure TToonAfspeler.handleUpdateStatus(aOk: Boolean; const aMelding: String);
begin
  FOk := aOk;
  FMelding := aMelding;
  if Assigned(OnStatusUpdate) then
    OnStatusUpdate(aOk, aMelding);
end;

end.
