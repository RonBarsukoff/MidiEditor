unit cmpToonInspeler;

interface

uses
  Classes, SysUtils,
  uCommonTypes,
  uMidiConstants,
  uMidiDevices,
  uMidiInDevice;

type
  TToonInspeler = class(TObject)
  private
    FMidiInDevice: TMidiInDevice;
    FOk: Boolean;
    FMelding: String;
    FMidiDevices: TMidiDevices;
    procedure UpdateStatus(aOK: Boolean; const aMelding: String);
    procedure handleToonEvent(aToon: TAfspeelToon);
  public
    LuisterNaarKanaal: array[1..midiMaxKanalen] of boolean;
    AantalHalveTonenHoger: Integer;
    GebruikKanalenMap: Boolean;
    KanaalUit: array[1..midiMaxKanalen] of Byte;
    OnStatusUpdate: TUpdateStatusEvent;
    OnToonEvent: TToonInEvent;
    constructor Create;
    destructor Destroy; override;
    procedure Init(const aMidiInDeviceName: String);
    procedure Done;
    property Melding: String read FMelding;
    property OK: Boolean read FOk;
  end;

implementation
uses
  uMidiDeviceFactory;

constructor TToonInspeler.Create;
var
  I: Integer;
begin
  inherited Create;
  for I := 1 to midiMaxKanalen do
    LuisterNaarKanaal[I] := True;
  FMidiDevices := CreateMidiDevices;
end;

destructor TToonInspeler.Destroy;
begin
  FMidiDevices.Free;
  inherited Destroy;
end;

procedure TToonInspeler.Init(const aMidiInDeviceName: String);
begin
  FMidiInDevice := FMidiDevices.GetInDevice(aMidiInDeviceName);
  if FMidiInDevice = nil then
    UpdateStatus(False, 'Ongeldig midi in apparaat: '+ aMidiInDeviceName)
  else
  begin
    FMidiInDevice.OnToonEvent := handleToonEvent;
    FMidiInDevice.IsOpen := True;
  end;
end;

procedure TToonInspeler.Done;
begin
  if Assigned(FMidiInDevice) then
    FMidiInDevice.IsOpen := False;
end;

procedure TToonInspeler.UpdateStatus(aOK: Boolean; const aMelding: String);
begin
  if Assigned(OnStatusUpdate) then
    OnStatusUpdate(aOk, aMelding)
end;

procedure TToonInspeler.handleToonEvent(aToon: TAfspeelToon);
begin
  if Assigned (OnToonEvent) then
    OnToonEvent(aToon);
end;

end.

