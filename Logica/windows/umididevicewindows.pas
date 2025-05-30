unit uMidiDeviceWindows;

interface

uses
  Classes;

type
  TMidiDeviceWindows = class(TMidiDevice)
  public
    procedure LeesInDevices(S: TStrings); override;
    procedure LeesOutDevices(S: TStrings); override;
    function GetInDeviceId(const aMidiInDeviceName: String): Integer; override;
    function GetOutDeviceId(const aMidiOutDeviceName: String): Integer; override;
  end;

implementation

uses
  SysUtils,
  uMMProcs,
  uMidiConstants;

procedure TMidiDeviceWindows.LeesInDevices(S: TStrings);
var Aantal, I: integer; P: TMidiInCaps; R: integer;
begin
  S.Clear;
  Aantal := midiInGetNumDevs;
  for I := 0 to Aantal -1 do
  begin
    R := midiInGetDevCaps(I, @P, SizeOf(P));
    if R = 0 then
      S.Add(StrPas(P.szPName));
  end;
  R := MidiInGetDevCaps(midi_mapper, @P, SizeOf(P));
  if R = 0 then
    S.Add(StrPas(P.szPName));
end;

procedure TMidiDeviceWindows.LeesOutDevices(S: TStrings);
var Aantal, I: integer; P: TMidiOutCaps; R: integer;
begin
  S.Clear;
  Aantal := midiOutGetNumDevs;
  for I := 0 to Aantal -1 do
  begin
    R := midiOutGetDevCaps(I, @P, SizeOf(P));
    if R = 0 then
      S.Add(StrPas(P.szPName));
  end;
  R := MidiOutGetDevCaps(midi_mapper, @P, SizeOf(P));
  if R = 0 then
    S.Add(StrPas(P.szPName));
end;

function TMidiDeviceWindows.GetInDeviceId(const aMidiInDeviceName: String): Integer;
var
  S: TStrings;
begin
  S := TStringList.Create;
  try
    LeesInDevices(S);
    Result := S.IndexOf(aMidiInDeviceName)
  finally
    S.Free;
  end;
end;

function TMidiDeviceWindows.GetOutDeviceId(const aMidiOutDeviceName: String): Integer;
var
  S: TStrings;
begin
  S := TStringList.Create;
  try
    LeesOutDevices(S);
    Result := S.IndexOf(aMidiOutDeviceName)
  finally
    S.Free;
  end;
end;

end.

