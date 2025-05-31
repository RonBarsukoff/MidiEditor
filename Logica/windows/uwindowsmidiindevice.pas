unit uWindowsMidiInDevice;

interface

uses
  Classes, SysUtils, MMSystem,

  uTypes,
  uMidiInDevice,
  uMidiConstants,
  uCommonTypes;

type
  TWindowsMidiInDevice = class(TMidiInDevice)
  private
    FId: UInt;
    FMidiInHandle: HMidiOut;
    FLastMMResult: MMRESULT;
    FLuisterNaarKanaal: array[1..midiMaxKanalen] of boolean;
  protected
    procedure Open; override;
    procedure Close; override;
    function GetIsOpen: Boolean; override;
  public
    constructor Create(aId: UInt);
    procedure MidiInCallback(aMidiIn: HMidiIn; aMsg: UInt; aInstance: Pointer; P1, P2: LongInt);
    procedure HandleMimData(P1, P2: LongInt);
  end;

implementation

var
  GlobalMidiInDevice: TWindowsMidiInDevice;

procedure MidiInCallback2(aMidiIn: HMidiIn; aMsg: UInt; aInstance: Pointer; P1, P2: LongInt); stdcall; export;
begin
  GlobalMidiInDevice.MidiInCallback(aMidiIn, aMsg, aInstance, P1, P2);
end;

constructor TWindowsMidiInDevice.Create(aId: UInt);
var
  I: Integer;
begin
  inherited Create;
  FId := aId;
  for I := 1 to midiMaxKanalen do
    FLuisterNaarKanaal[I] := True;
end;

procedure TWindowsMidiInDevice.Open;
begin
  GlobalMidiInDevice := Self;
  FLastMMResult := midiInOpen(@FMidiInHandle, FId, DWord_PTR(@MidiInCallback2), 0, callback_function);
  if FLastMMResult = mmsyserr_noError then
    FLastMMResult := midiInStart(FMidiInHandle);
end;

procedure TWindowsMidiInDevice.Close;
begin
  FLastMMResult := midiInClose(FMidiInHandle);
  GlobalMidiInDevice := nil;
end;

function TWindowsMidiInDevice.GetIsOpen: Boolean;
begin
  Result := FMidiInHandle > 0;
end;

procedure TWindowsMidiInDevice.MidiInCallback(aMidiIn: HMidiIn; aMsg: UInt; aInstance: Pointer; P1, P2: LongInt);
begin
  case aMsg of
    mim_Data:
      HandleMimData(P1, P2);
  end;
end;

type
  TMidiInMessage = record Msg, Hoogte, Velocity, Dummy: byte; end;

procedure TWindowsMidiInDevice.HandleMimData(P1, P2: LongInt);
var
  R: TMidiInMessage;
  H, K: byte; //H2: integer;
  myAfspeelToon: TAfspeelToon;
begin
  R := TMidiInMessage(P1);
  H := R.Msg and $F0;
  K := (R.Msg and $0F) + 1;
  if FLuisterNaarKanaal[K]
  and (H >= note_off)
  and (H <= pitch_wheel) then
  begin
    if (H = note_on)
    and (R.Velocity = 0) then
    begin
      R.Msg := note_off + K-1;  // +K-1 21-8-7 van der Sanden
      Move(R, P1, SizeOf(P1));
    end;
    if Assigned(OnToonEvent) then
    begin
      myAfspeelToon.Aan:= H = note_on;
      myAfspeelToon.Hoogte:= R.Hoogte;
      myAfspeelToon.Velocity:= R.Velocity;
      myAfspeelToon.Kanaal:= 0;
      myAfspeelToon.Lengte:= 1;
      OnToonEvent(myAfspeelToon);
    end;
//    PostMessage(MidiData^.mdHWindow, wm_MidiData, P1, P2);
    //if HMidiUit <> 0 then
    //begin
    //  H2 := R.Hoogte;
    //  Inc(H2, AantalHalveTonenHoger);
    //  if H2 < 0 then
    //    R.Hoogte := 0
    //  else if H2 > 127 then
    //    R.Hoogte := 127
    //  else
    //    R.Hoogte := H2;
    //  if GebruikKanalenMap then
    //  begin
    //    H := R.Msg and $0F;
    //    R.Msg := ((R.Msg and $F0) or KanaalUit[H+1]-1);
    //  end;
    //  Move(R, P1, SizeOf(P1));
    //  MidiOutShortMsg(HMidiUit, P1);
    //end;
  end;
end;

end.

