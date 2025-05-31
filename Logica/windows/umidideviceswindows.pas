unit uMidiDevicesWindows;

interface

uses
  Classes,
  uMidiDevices;

type
  TMidiDevicesWindows = class(TMidiDevices)
  private
  public
    procedure LeesInDevices; override;
    procedure LeesOutDevices; override;
  end;

implementation
uses
  uTypes,
  uMMProcs,
  uMidiConstants,
  uWindowsMidiInDevice,
  uWindowsMidiOutDevice;

procedure TMidiDevicesWindows.LeesInDevices;
var
  Aantal,
  I: integer;
  P: TMidiInCaps;
  R: integer;
  myMidiDevice: TWindowsMidiInDevice;
begin
  ClearMidiInDevices;
  Aantal := midiInGetNumDevs;
  for I := 0 to Aantal -1 do
  begin
    R := midiInGetDevCaps(I, @P, SizeOf(P));
    if R = 0 then
    begin
      myMidiDevice := TWindowsMidiInDevice.Create(I);
      fInDeviceList.AddObject(P.szPName, myMidiDevice)
    end;
  end;
  R := MidiInGetDevCaps(midi_mapper, @P, SizeOf(P));
  if R = 0 then
  begin
    myMidiDevice := TWindowsMidiInDevice.Create(UInt(midi_mapper));
    fInDeviceList.AddObject(P.szPName, myMidiDevice)
  end;
end;

procedure TMidiDevicesWindows.LeesOutDevices;
var
  myAantal,
  I: integer;
  P: TMidiOutCaps;
  R: integer;
  myMidiDevice: TWindowsMidiOutDevice;
begin
  ClearMidiOutDevices;
  myAantal := midiOutGetNumDevs;
  for I := 0 to myAantal-1  do
  begin
    R := midiOutGetDevCaps(I, @P, SizeOf(P));
    if R = 0 then
    begin
      myMidiDevice := TWindowsMidiOutDevice.Create(I);
      fOutDeviceList.AddObject(P.szPName, myMidiDevice)
    end;
  end;
  R := MidiOutGetDevCaps(midi_mapper, @P, SizeOf(P));
  if R = 0 then
  begin
    myMidiDevice := TWindowsMidiOutDevice.Create(UInt(midi_mapper));
    fOutDeviceList.AddObject(P.szPName, myMidiDevice)
  end;
end;

end.

