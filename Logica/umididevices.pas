unit uMidiDevices;

interface
uses
  Classes,

  uMidiInDevice,
  uMidiOutDevice;

type
  TMidiDevices = class(TObject)
  protected
    FAppName: String;
    FOutDeviceList: TStringList;
    FInDeviceList: TStringList;
    procedure ClearMidiOutDevices;
    procedure ClearMidiInDevices;
  public
    constructor Create(aAppName: String);
    destructor Destroy; override;
    procedure LeesInDevices; virtual; abstract;
    procedure LeesOutDevices; virtual; abstract;
    function GetInDevice(const aMidiInDeviceName: String): TMidiInDevice;
    function GetOutDevice(const aMidiOutDeviceName: String): TMidiOutDevice;
    property OutDeviceList: TStringList read FOutDeviceList;
    property InDeviceList: TStringList read FInDeviceList;
  end;

implementation

constructor TMidiDevices.Create(aAppName: String);
begin
  inherited Create;
  FAppName := aAppName;
  FOutDeviceList := TStringList.Create;
  FInDeviceList := TStringList.Create;
end;

destructor TMidiDevices.Destroy;
begin
  ClearMidiOutDevices;
  ClearMidiInDevices;
  FOutDeviceList.Free;
  FInDeviceList.Free;
  inherited Destroy;
end;

procedure TMidiDevices.ClearMidiOutDevices;
var
  I: Integer;
begin
  for I := 0 to FOutDeviceList.Count-1 do
    FOutDeviceList.Objects[I].Free;
  FOutDeviceList.Clear;
end;

procedure TMidiDevices.ClearMidiInDevices;
var
  I: Integer;
begin
  for I := 0 to FInDeviceList.Count-1 do
    FInDeviceList.Objects[I].Free;
  FInDeviceList.Clear;
end;

function TMidiDevices.GetInDevice(const aMidiInDeviceName: String): TMidiInDevice;
var
  myIndex: Integer;
begin
  LeesInDevices;
  myIndex := FInDeviceList.IndexOf(aMidiInDeviceName);
  if myIndex >= 0 then
    Result := FInDeviceList.Objects[myIndex] as TMidiInDevice
  else
    Result := nil;
end;

function TMidiDevices.GetOutDevice(const aMidiOutDeviceName: String): TMidiOutDevice;
var
  myIndex: Integer;
begin
  LeesOutDevices;
  myIndex := FOutDeviceList.IndexOf(aMidiOutDeviceName);
  if myIndex >= 0 then
    Result := FOutDeviceList.Objects[myIndex] as TMidiOutDevice
  else
    Result := nil;
end;

end.
