unit uWindowsMidiOutDevice;

interface

uses
  Classes, SysUtils, MMSystem,

  uMidiOutDevice,
  uTypes;

type
  TWindowsMidiOutDevice = class(TMidiOutDevice)
  private
    FId: UInt;
    FUitHandle: HMidiOut;
    FLastMMResult: MMRESULT;
  protected
    function GetIsOpen: Boolean; override;
    procedure Open; override;
    procedure Close; override;
  public
    constructor Create(aId: UInt);
    procedure ToonAan(aKanaal, aHoogte, aVelocity: byte); override;
  end;

implementation
uses
  uMMProcs,
  uMidiConstants;

constructor TWindowsMidiOutDevice.Create(aId: UInt);
begin
  inherited Create;
  FId := aId;
end;

function TWindowsMidiOutDevice.GetIsOpen: Boolean;
begin
  Result := FUitHandle > 0;
end;

procedure TWindowsMidiOutDevice.Open;
begin
  FLastMMResult := midiOutOpen(@FUitHandle, FId, 0, 0, callback_null);

end;

procedure TWindowsMidiOutDevice.Close;
begin
  FLastMMResult := midiOutClose(FUitHandle);
end;

type
  TMidiOutShortMessage = record
    Event, Hoogte, Velocity, Dummy: Byte
  end;

procedure TWindowsMidiOutDevice.ToonAan(aKanaal, aHoogte, aVelocity: byte);
var
  M: TMidiOutShortMessage;
begin
  if FUitHandle <> 0 then
  begin
    M.Dummy := 0;
    M.Velocity := aVelocity;
    M.Hoogte := aHoogte;
    M.Event := Note_On + aKanaal;
    FLastMMResult := midiOutShortMsg(FUitHandle, LongInt(M));
    if FLastMMResult <> MMSYSERR_NOERROR then
      FLastResult := MMResultString(FLastMMResult);
  end;
end;

end.

