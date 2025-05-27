unit cmpAfspeelThread;

interface

uses
  Classes, SysUtils,

  uMidiDevices,
  uMidiOutDevice,
  uCommonTypes;

type
  TAfspeelThread = class(TThread)
  private
    FMidiOutDevice: TMidiOutDevice;
    //FLastMMResult: MMRESULT;

    FAfspeelToon: TAfspeelToon;
    FAskStopToonResult: Boolean;
    FNieuweAfspeelToon: TAfspeelToon;
    FGetNieuweToonResult: Boolean;
    FMidiDevices: TMidiDevices;
    FOutDeviceName: String;
    FOk: Boolean;
    FMelding: String;
    FNieuweOk: Boolean;
    FNieuweMelding: String;
    FForceUpdate: Boolean;
    procedure StopToon;
    procedure StartToon;
    procedure AskStopToon;
    procedure GetNieuweToon;
    procedure UpdateStatus;

    procedure NootAan(aKanaal, aHoogte, aVelocity: Byte);
    procedure NootUit(aKanaal, aHoogte: Byte);
    function LastResultMelding: String;
    function Ok: Boolean;

  public
    OnGetToon: TGetToonEvent;
    OnAskStopToon: TAskStopToonEvent;
    OnUpdateStatus: TUpdateStatusEvent;
    constructor Create(const aMidiOutDeviceName: String);
    destructor Destroy; override;
    procedure Execute; override;
  end;

implementation
uses
  uMidiDeviceFactory,
  uMidiConstants;

constructor TAfspeelThread.Create(const aMidiOutDeviceName: String);
begin
  inherited Create(True);
  FMidiDevices := CreateMidiDevices;
  FOutDeviceName := aMidiOutDeviceName;
end;

destructor TAfspeelThread.Destroy;
begin
  FMidiDevices.Free;
  inherited Destroy;
end;

procedure TAfspeelThread.Execute;
begin
  FOk := True;
  FForceUpdate := True;
  FMidiDevices.LeesOutDevices;
  FMidiOutDevice := FMidiDevices.GetOutDevice(FOutDeviceName);
  if not Assigned(FMidiOutDevice) then
  begin
    FOk := False;
    FNieuweMelding := Format('Ongeldig midi uit apparaat: %s', [FOutDeviceName]);
    Synchronize(UpdateStatus);
  end
  else
  begin
    FMidiOutDevice.IsOpen := True;
    if Ok then
    begin
      try
        while not Terminated do
        begin
          Synchronize(AskStopToon);
          if FAskStopToonResult then
            StopToon
          else if FAfspeelToon.Lengte > 0 then
          begin
            Dec(FAfspeelToon.Lengte);
            if FAfspeelToon.Lengte = 0 then
              StopToon;
          end;
          Synchronize(GetNieuweToon);
          if FGetNieuweToonResult then
          begin
            StopToon;
            FAfspeelToon := FNieuweAfspeelToon;
            StartToon;
          end;
          FNieuweOk := True;
          FNieuweMelding := LastResultMelding;
          Synchronize(UpdateStatus);
          Sleep(1);
        end;
      finally
        FMidiOutDevice.IsOpen:= False;
      end;
    end
    else
    begin
      FNieuweOk := False;
      FNieuweMelding := LastResultMelding;
      Synchronize(UpdateStatus);
      Terminate;
    end;
  end;
end;

procedure TAfspeelThread.StopToon;
begin
  with FAfspeelToon do
    if Aan then
  begin
    NootUit(FAfspeelToon.Kanaal, FAfspeelToon.Hoogte);
    FAfspeelToon.Aan := False;
  end;
end;

procedure TAfspeelThread.StartToon;
begin
  with FAfspeelToon do
    NootAan(Kanaal, Hoogte, Velocity)
end;

procedure TAfspeelThread.AskStopToon;
begin
  if Assigned(OnAskStopToon) then
    FAskStopToonResult := OnAskStopToon;
end;

procedure TAfspeelThread.GetNieuweToon;
begin
  if Assigned(OnGetToon) then
     FGetNieuweToonResult := OnGetToon(FNieuweAfspeelToon)
end;

procedure TAfspeelThread.UpdateStatus;
begin
  if FForceUpdate or (FOk <> FNieuweOk) or (FMelding <> FNieuweMelding) then
  begin
    FOk := FNieuweOk;
    FMelding := FNieuweMelding;
    if Assigned(OnUpdateStatus) then
      OnUpdateStatus(FOk, FNieuweMelding);
  end;
end;

procedure TAfspeelThread.NootAan(aKanaal, aHoogte, aVelocity: Byte);
begin
  if Assigned(FMidiOutDevice) then
    FMidiOutDevice.ToonAan(aKanaal, aHoogte, aVelocity);
end;

procedure TAfspeelThread.NootUit(aKanaal, aHoogte: Byte);
begin
  if Assigned(FMidiOutDevice) then
    FMidiOutDevice.ToonAan(aKanaal, aHoogte, 0);
end;

function TAfspeelThread.LastResultMelding: String;
begin
  Result := FMidiOutDevice.LastResult;
end;

function TAfspeelThread.Ok: Boolean;
begin
  Result := FMidiOutDevice.IsOk;
end;


end.

