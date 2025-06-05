unit uMidiDeviceFactory;

interface

uses
  Classes, SysUtils,
  uMidiDevices;

function CreateMidiDevices(aAppName: String='MidiEditor'): TMidiDevices;

implementation
uses
{$ifdef Windows}
   uMidiDevicesWindows
{$else}
  uMidiDevicesLinux
{$endif}
;

function CreateMidiDevices(aAppName: String): TMidiDevices;
begin
  {$ifdef Windows}
    Result := TMidiDevicesWindows.Create(aAppName);
  {$else}
    Result := TMidiDevicesLinux.Create(aAppName);
  {$endif}
end;

end.

