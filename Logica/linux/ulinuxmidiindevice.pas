unit uLinuxMidiIndevice;

interface

uses
  Classes, SysUtils,

  asoundlib,
  uAlsaDevice,
  uCommonTypes,
  uLinuxMidiInspeelThread,
  uMidiInDevice;

type
  TLinuxMidiInDevice = class(TMidiInDevice)
  private
    FAlsaDevice: TAlsaDevice;
    FSubscription:Psnd_seq_port_subscribe_t;
    FSubscribed: Boolean;
    //FCoder: Psnd_midi_event_t;
    FInspeelThread: TLinuxMidiInspeelThread;
    procedure Subscribe;
    procedure UnSubscribe;
    procedure Warning(aMessage: String);
    procedure GetMidiInEvents;
    procedure handleToonEvent(aAfspeelToon: TAfspeelToon);
  protected
    procedure Open; override;
    procedure Close; override;
    function GetIsOpen: Boolean; override;
  public
    constructor Create(aAppName: String);
    destructor Destroy; override;
    procedure Init(aSeqHandle: Psnd_seq_t; aPortInfo: Psnd_seq_port_info_t;
      aClientinfo: Psnd_seq_client_info_t);
  end;

implementation
uses
  cTypes;

constructor TLinuxMidiInDevice.Create(aAppName: String);
begin
  inherited Create;
  FAlsaDevice := TAlsaDevice.Create(aAppName);
end;

destructor TLinuxMidiInDevice.Destroy;
begin
  FAlsaDevice.Free;
  inherited Destroy;
end;

procedure TLinuxMidiInDevice.Init(aSeqHandle: Psnd_seq_t; aPortInfo: Psnd_seq_port_info_t;
  aClientinfo: Psnd_seq_client_info_t);
begin
  FAlsaDevice.Client := snd_seq_client_info_get_client(aClientinfo);
  FAlsaDevice.Capabilities := snd_seq_port_info_get_capability(aPortinfo);
  FAlsaDevice.Sender.client := snd_seq_port_info_get_client(aPortinfo);
  FAlsaDevice.Sender.Port := snd_seq_port_info_get_port(aPortInfo);
  FAlsaDevice.Destination.Client := snd_seq_client_id(aSeqHandle);
  FAlsaDevice.PortType := snd_seq_port_info_get_type(aPortInfo);
  FAlsaDevice.ClientName := snd_seq_client_info_get_name(aClientInfo);
  FAlsaDevice.PortName := snd_seq_port_info_get_name(aPortInfo);
end;

procedure TLinuxMidiInDevice.GetMidiInEvents;
var
  r: integer;
  ev: psnd_seq_event_t;
  myAfspeelToon: TAfspeelToon;
  myType: snd_seq_event_type;
begin
  r:= snd_seq_event_input(FAlsaDevice.SeqHandle, @ev );
  if r < 0 then
    Warning(snd_strError(r));
  while ( r > 0 ) do
  begin
    myType := snd_seq_event_type(ev.type_);
    if myType in [SND_SEQ_EVENT_NOTE, SND_SEQ_EVENT_NOTEON, SND_SEQ_EVENT_NOTEOFF, SND_SEQ_EVENT_KEYPRESS] then
    begin
      myAfspeelToon.Aan := ev^.data.note.velocity <> 0;
      myAfspeelToon.Hoogte:= ev^.data.note.note;
      myAfspeelToon.Velocity:= ev^.data.note.velocity;
      myAfspeelToon.Kanaal:= ev^.data.note.channel;
      myAfspeelToon.Lengte:= 1;
      OnToonEvent(myAfspeelToon);
    end;
    r:= snd_seq_event_input(FAlsaDevice.SeqHandle, @ev );
  end;
end;

procedure TLinuxMidiInDevice.Subscribe;
var
  myStatus: Integer;
begin
  if not FSubscribed then
  begin
    // Make subscription
    myStatus := snd_seq_port_subscribe_malloc(@FSubscription);
    if myStatus < 0 then
    begin
      Warning('error allocating port subscription. ' + snd_strError(myStatus));
      snd_seq_port_subscribe_free(FSubscription);  // is dit juist ?
    end
    else
    begin
    snd_seq_port_subscribe_set_sender(FSubscription, @FAlsaDevice.Sender);
    snd_seq_port_subscribe_set_dest(FSubscription, @FAlsaDevice.Destination);
    myStatus := snd_seq_subscribe_port(FAlsaDevice.SeqHandle, FSubscription);
    if myStatus <> 0 then
    begin
      Warning('ALSA error making port connection. ' + snd_strError(myStatus));
      snd_seq_port_subscribe_free(FSubscription ); // is dit juist ?
    end
    else
      FSubscribed := true;
    end;
  end;
end;

procedure TLinuxMidiInDevice.Unsubscribe;
var
  myStatus: Integer;
begin
  if FSubscribed then
  begin
    myStatus := snd_seq_unsubscribe_port(FAlsaDevice.SeqHandle, FSubscription );
    if myStatus < 0 then
      Warning('error unsubscribing port. ' + snd_strError(myStatus))
    else
    begin
      snd_seq_port_subscribe_free(FSubscription );
      FSubscription :=NIL;
      FSubscribed := false;
    end;
  end;
end;

procedure TLinuxMidiInDevice.Open;
var
  myStatus: Integer;
  myPortInfo: Psnd_seq_port_info_t;
  myPort: cint;
  myQueueId: Integer;
  myTempo: Psnd_seq_queue_tempo_t;
begin
  FAlsaDevice.IsOpen := False;
  myStatus := snd_seq_open(@FAlsaDevice.SeqHandle, 'default', SND_SEQ_OPEN_DUPLEX, SND_SEQ_NONBLOCK);
  if myStatus < 0 then begin
    Warning('Cannot open sequencer for ALSA device input: ' + snd_strError(myStatus));
    exit
  end;

  myStatus := snd_seq_set_client_name(FAlsaDevice.SeqHandle, PChar(FAlsaDevice.AppName));
  if myStatus < 0 then
  begin
    Warning('Cannot set ALSA client name: ' + snd_strError(myStatus));
    exit
  end;

  myStatus := snd_seq_port_info_malloc(@myPortInfo);
  if myStatus < 0 then
  begin
    Warning('Cannot allocate ALSA port_info memory: ' + snd_strError(myStatus));
    exit
  end;
  try
    FAlsaDevice.QueueId := snd_seq_alloc_named_queue(FAlsaDevice.SeqHandle, 'Mijn Midi queue');
    myStatus := snd_seq_queue_tempo_malloc(@myTempo);
    snd_seq_queue_tempo_set_tempo(myTempo, 600000);
    snd_seq_queue_tempo_set_ppq(myTempo, 240);
    myStatus := snd_seq_set_queue_tempo(FAlsaDevice.SeqHandle, FAlsaDevice.QueueId, myTempo);
    myStatus := snd_seq_drain_output(FAlsaDevice.SeqHandle);

    snd_seq_port_info_set_client(myPortInfo, 0 ); // overgenomen uit RtMidi.cpp
    snd_seq_port_info_set_port(myPortInfo, 0); (* Defaults to 0, this for safety *)
    snd_seq_port_info_set_port_specified(myPortInfo, 1);
    snd_seq_port_info_set_name(myPortInfo, PChar(FAlsaDevice.AppName));
    snd_seq_port_info_set_capability(myPortInfo, SND_SEQ_PORT_CAP_WRITE or SND_SEQ_PORT_CAP_SUBS_WRITE);
    snd_seq_port_info_set_type(myPortInfo, SND_SEQ_PORT_TYPE_MIDI_GENERIC or SND_SEQ_PORT_TYPE_APPLICATION);
    snd_seq_port_info_set_midi_channels(myPortInfo, 16);

    snd_seq_port_info_set_timestamp_real(myPortInfo, 1);
    snd_seq_port_info_set_timestamping(myPortInfo, 1);
    snd_seq_port_info_set_timestamp_queue(myPortInfo, FAlsaDevice.QueueId);

    myPort := snd_seq_create_port(FAlsaDevice.SeqHandle, myPortInfo);
    if myPort < 0 then
    begin
      Warning('Cannot create ALSA source port: ' + snd_strError(myPort));
      exit
    end;
    FAlsaDevice.Destination.port := myPort;
    myQueueId := snd_seq_port_info_get_timestamp_queue(myPortInfo);
    snd_seq_port_info_set_timestamp_queue(myPortInfo, myQueueId);

  finally
    snd_seq_port_info_free(myPortInfo);
  end;

  Subscribe;
  myStatus := snd_seq_start_queue(FAlsaDevice.SeqHandle, FAlsaDevice.QueueId, nil);
  myStatus := snd_seq_drain_output(FAlsaDevice.SeqHandle);
  if myStatus < 0 then
    Warning('snd_seq_drain_output: ' + snd_strError(myStatus))
  else
  begin
    FInspeelThread := TLinuxMidiInspeelThread.Create(True);
    FInspeelThread.SeqHandle := FAlsaDevice.SeqHandle;
    FInspeelThread.OnToonEvent := handleToonEvent;
    FInspeelThread.Start;
    FAlsaDevice.IsOpen := True;
  end;
end;

procedure TLinuxMidiInDevice.Close;
var
  myStatus: Integer;
begin
  myStatus := snd_seq_free_queue(FAlsaDevice.SeqHandle, FAlsaDevice.QueueId);
  if myStatus < 0 then
    Warning('snd_seq_drain_output: ' + snd_strError(myStatus));
  if Assigned(FInspeelThread) then
  begin
    FInspeelThread.Terminate;
    FreeAndNil(FInspeelThread);
  end;
  UnSubscribe;
  FAlsaDevice.Close;
end;

function TLinuxMidiInDevice.GetIsOpen: Boolean;
begin
  Result := FAlsaDevice.IsOpen;
end;

procedure TLinuxMidiInDevice.Warning(aMessage: String);
begin
  WriteLn(aMessage)
end;

procedure TLinuxMidiInDevice.handleToonEvent(aAfspeelToon: TAfspeelToon);
begin
  if Assigned(OnToonEvent) then
    OnToonEvent(aAfspeelToon);
end;

end.

