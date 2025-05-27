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
    FStatus: Integer;
    FOk: Boolean;
    FMelding: String;
    FMidiDevices: TMidiDevices;
    //procedure MidiInCallback(aMidiIn: HMidiIn; aMsg: UInt; aInstance: Pointer; P1, P2: LongInt);
    procedure handleMidiInEvent(aBuffer:TMidiBuffer; size:integer);
    //procedure StopMidiIn;
    //procedure HandleMimData(P1, P2: LongInt);
    procedure UpdateStatus(aOK: Boolean; const aMelding: String);
  public
    LuisterNaarKanaal: array[1..midiMaxKanalen] of boolean;
    //HMidiUit: HMIDIOUT;
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

var
  GlobalToonInspeler: TToonInspeler;
(*
procedure MidiInCallback2(aMidiIn: HMidiIn; aMsg: UInt; aInstance: Pointer; P1, P2: LongInt); stdcall; export;
begin
  GlobalToonInspeler.MidiInCallback(aMidiIn, aMsg, aInstance, P1, P2);
end;
*)
procedure TToonInspeler.handleMidiInEvent(aBuffer:TMidiBuffer; size:integer);
begin

end;

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
  GlobalToonInspeler := nil;
  FMidiDevices.Free;
  inherited Destroy;
end;

procedure TToonInspeler.Init(const aMidiInDeviceName: String);
begin
  FMidiInDevice := FMidiDevices.GetInDevice(aMidiInDeviceName);
  if FMidiInDevice = nil then
    UpdateStatus(False, 'Ongeldig midi in apparaat: '+ aMidiInDeviceName)
  else
    FMidiInDevice.IsOpen := True;
end;

procedure TToonInspeler.Done;
begin
  if Assigned(FMidiInDevice) then
    FMidiInDevice.IsOpen := False;
end;
(*
procedure TToonInspeler.MidiInCallback(aMidiIn: HMidiIn; aMsg: UInt; aInstance: Pointer; P1, P2: LongInt);
begin
  case aMsg of
    mim_Data:
      HandleMimData(P1, P2);
  end;
end;

type
  TMidiInMessage = record Msg, Hoogte, Velocity, Dummy: byte; end;
(*
procedure TToonInspeler.HandleMimData(P1, P2: LongInt);
var
  R: TMidiInMessage;
  H, K: byte; H2: integer;
  myAfspeelToon: TAfspeelToon;
begin
  R := TMidiInMessage(P1);
  H := R.Msg and $F0;
  K := (R.Msg and $0F) + 1;
  if LuisterNaarKanaal[K]
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
    if HMidiUit <> 0 then
    begin
      H2 := R.Hoogte;
      Inc(H2, AantalHalveTonenHoger);
      if H2 < 0 then
        R.Hoogte := 0
      else if H2 > 127 then
        R.Hoogte := 127
      else
        R.Hoogte := H2;
      if GebruikKanalenMap then
      begin
        H := R.Msg and $0F;
        R.Msg := ((R.Msg and $F0) or KanaalUit[H+1]-1);
      end;
      Move(R, P1, SizeOf(P1));
      MidiOutShortMsg(HMidiUit, P1);
    end;
  end;
end;

procedure TToonInspeler.StartMidiIn(MidiInId: word);
begin
  GlobalToonInspeler := Self;
  FStatus := midiInOpen(@FMidiInHandle, MidiInId, DWord_PTR(@MidiInCallback2), 0, callback_function);
  if FStatus = mmsyserr_noError then
    FStatus := midiInStart(FMidiInHandle);
end;

procedure TToonInspeler.StopMidiIn;
begin
  FStatus := midiInClose(FMidiInHandle);
end;
*)
procedure TToonInspeler.UpdateStatus(aOK: Boolean; const aMelding: String);
begin
  if Assigned(OnStatusUpdate) then
    OnStatusUpdate(aOk, aMelding)
end;

end.

