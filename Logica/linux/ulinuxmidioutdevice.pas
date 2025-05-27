unit uLinuxMidiOutDevice;

interface

uses
  Classes, SysUtils,

  asoundlib,
  uAlsaDevice,
  uMidiOutDevice;

type
  TLinuxMidiOutDevice = class(TMidiOutDevice)
  private
    FAlsaDevice: TAlsaDevice;
    FSeqQueue: longint;
    FQueueAllocated: Boolean;
  protected
    function GetIsOpen: Boolean; override;
    procedure Open; override;
    procedure Close; override;
  public
    constructor Create(aAppName: String);
    destructor Destroy; override;
    procedure Init(aSeqHandle: Psnd_seq_t; aPortInfo: Psnd_seq_port_info_t;
      aClientinfo: Psnd_seq_client_info_t);
    procedure ToonAan(aKanaal, aHoogte, aVelocity: byte); override;
    procedure SendShortMessage(aMessage: LongInt); override;
    property AlsaDevice: TAlsaDevice read FAlsaDevice;
  end;

implementation
uses
  cTypes;

constructor TLinuxMidiOutDevice.Create(aAppName: String);
begin
  inherited Create;
  FAlsaDevice := TAlsaDevice.Create(aAppName);
end;

destructor TLinuxMidiOutDevice.Destroy;
begin
  FAlsaDevice.Free;
  inherited Destroy;
end;

procedure TLinuxMidiOutDevice.Open;
var
  myStatus: Integer;
  myPortInfo: Psnd_seq_port_info_t;
  myPort: cint;
begin
  FAlsaDevice.IsOpen := False;
  FLastResult := '';
  myStatus := snd_seq_open(@FAlsaDevice.SeqHandle, 'default', SND_SEQ_OPEN_DUPLEX, SND_SEQ_NONBLOCK);
  if myStatus < 0 then begin
    FLastResult := 'Cannot open sequencer for ALSA device output: ' + snd_strError(myStatus);
    exit
  end;

  myStatus := snd_seq_set_client_name(FAlsaDevice.SeqHandle, PChar(FAlsaDevice.AppName));
  if myStatus < 0 then
  begin
    FLastResult := 'Cannot set ALSA client name: ' + snd_strError(myStatus);
    exit
  end;

(* We already have the client and port number from parsing the available ports, *)
(* confirmed by the user if there was more than one possibility. Create a       *)
(* source port which is used to originate MIDI events, even if each event is    *)
(* populated by code here rather than by a hardware or software MIDI device.    *)


  myStatus := snd_seq_port_info_malloc(@myPortInfo);
  if myStatus < 0 then
  begin
    FLastResult := 'Cannot allocate ALSA port_info memory: ' + snd_strError(myStatus);
    exit
  end;
  try
    snd_seq_port_info_set_port(myPortInfo, 0); (* Defaults to 0, this for safety *)
    snd_seq_port_info_set_port_specified(myPortInfo, 1);
    snd_seq_port_info_set_name(myPortInfo, PChar(FAlsaDevice.AppName));
    snd_seq_port_info_set_capability(myPortInfo, 0);
    snd_seq_port_info_set_type(myPortInfo, SND_SEQ_PORT_TYPE_MIDI_GENERIC or SND_SEQ_PORT_TYPE_APPLICATION);
    myPort := snd_seq_create_port(FAlsaDevice.SeqHandle, myPortInfo);
    if myPort < 0 then begin
      FLastResult := 'Cannot create ALSA source port: ' + snd_strError(myPort);
      exit
    end;
    myPort := FAlsaDevice.Destination.port;
  finally
    snd_seq_port_info_free(myPortInfo);
    myPortInfo := nil
  end;

(* Create a queue.                                                              *)
  FSeqQueue := snd_seq_alloc_named_queue(FAlsaDevice.SeqHandle, PChar(FAlsaDevice.AppName));
  if FSeqQueue < 0 then begin
    FLastResult := 'Cannot create ALSA queue: ' + snd_strError(FSeqQueue);
    exit
  end;
  FQueueAllocated := True;

  (* Connect the ports in order to keep the raw device open.                      *)
  myStatus := snd_seq_connect_to(FAlsaDevice.SeqHandle, 0, FAlsaDevice.Destination.client, FAlsaDevice.Destination.port);
  if myStatus < 0 then begin
    FLastResult := 'Cannot connect ALSA ports: ' + snd_strError(myStatus);
    exit
  end;
  myStatus := snd_seq_start_queue(FAlsaDevice.SeqHandle, FSeqQueue, nil);
  if myStatus < 0 then begin
    FLastResult := 'Cannot start ALSA queue: ' + snd_strError(myStatus);
    exit
  end;

  FAlsaDevice.IsOpen := True;
end;

const
  synthesizer= SND_SEQ_PORT_TYPE_SYNTHESIZER { or SND_SEQ_PORT_TYPE_PORT } ; (* Either required *)
  understandsMidi= SND_SEQ_PORT_TYPE_MIDI_GENERIC or SND_SEQ_PORT_TYPE_MIDI_GM or
                SND_SEQ_PORT_TYPE_MIDI_GS or SND_SEQ_PORT_TYPE_MIDI_XG or
                SND_SEQ_PORT_TYPE_MIDI_MT32 or SND_SEQ_PORT_TYPE_MIDI_GM2;

procedure TLinuxMidiOutDevice.Init(aSeqHandle: Psnd_seq_t; aPortInfo: Psnd_seq_port_info_t;
  aClientinfo: Psnd_seq_client_info_t);
begin
  FAlsaDevice.Client := snd_seq_client_info_get_client(aClientinfo);
  FAlsaDevice.Capabilities := snd_seq_port_info_get_capability(aPortinfo);
  FAlsaDevice.PortType := snd_seq_port_info_get_type(aPortInfo);
  FAlsaDevice.Destination.client := snd_seq_port_info_get_client(aPortinfo);
  FAlsaDevice.Destination.Port := snd_seq_port_info_get_port(aPortInfo);
  FAlsaDevice.Sender.client := snd_seq_client_id(aSeqHandle);
  FAlsaDevice.ClientName := snd_seq_client_info_get_name(aClientInfo);
  FAlsaDevice.PortName := snd_seq_port_info_get_name(aPortInfo);

(* Special cases: recognising known client names, adjust the capabilities to    *)
(* ensure that they appear in what we believe to be the correct combination of  *)
(* input and output lists. I'm not saying that the quirked capabilities would   *)
(* be correct according to the ALSA API, only that they force the comparisons   *)
(* below.                                                                       *)

  if FAlsaDevice.ClientName = 'QmidiNet' then (* MIDI networking protocol     *)
    if FAlsaDevice.Capabilities and SND_SEQ_PORT_CAP_DUPLEX = 0 then
      FAlsaDevice.Capabilities += SND_SEQ_PORT_CAP_DUPLEX;

(* If the type of port indicates that it "may connect to other devices (whose   *)
(* characteristics are not known)" and it understands MIDI and is writeable     *)
(* then assume it's an interface to an external sound generator.                *)

  if FAlsaDevice.PortType and SND_SEQ_PORT_TYPE_PORT <> 0 then
    if (FAlsaDevice.PortType and understandsMidi) <> 0 then
      if FAlsaDevice.Writable then
        if Pos('through', LowerCase(FAlsaDevice.PortName)) < 1 then
          FAlsaDevice.PortType += synthesizer;
  FLastResult := '';
end;

procedure TLinuxMidiOutDevice.ToonAan(aKanaal,aHoogte, aVelocity: byte);
var
  ev: snd_seq_event_t;
  myOk: Boolean;
  i: Integer;
begin
  snd_seq_ev_clear(@ev);
  ev.queue := FSeqQueue;
  ev.source.port := 0;
  ev.flags := SND_SEQ_TIME_STAMP_REAL + SND_SEQ_TIME_MODE_REL;
  ev.time.time.tv_sec := 0;
  ev.time.time.tv_nsec := 0;
  if aVelocity = 0 then
    ev.type_:= byte(SND_SEQ_EVENT_NOTEOFF)
  else
    ev.type_:= byte(SND_SEQ_EVENT_NOTEON);
  ev.data.note.channel := aKanaal;
  ev.data.note.velocity := aVelocity;
  ev.data.note.off_velocity := aVelocity;
  ev.data.note.note := aHoogte;
  ev.dest.client := FAlsaDevice.Destination.client;
  ev.dest.port := FAlsaDevice.Destination.port;
  myOk := True;
  i := snd_seq_event_output(FAlsaDevice.SeqHandle, @ev);
  if i < 0 then
    myOk := false;
  if myOk then
  begin
    i := snd_seq_drain_output(FAlsaDevice.SeqHandle);
    if i < 0 then
      myOk := false;
  end;
end;

procedure TLinuxMidiOutDevice.SendShortMessage(aMessage: LongInt);
var
  ev: snd_seq_event_t;
  myOk: Boolean;
  i: Integer;
begin
  snd_seq_ev_clear(@ev);
  ev.queue := FSeqQueue;
  ev.source.port := 0;
  ev.flags := SND_SEQ_TIME_STAMP_REAL + SND_SEQ_TIME_MODE_REL;
  ev.time.time.tv_sec := 0;
  ev.time.time.tv_nsec := 0;
  ev.type_ := byte(SND_SEQ_EVENT_OSS);
  ev.data.raw32.d[0] := byte(aMessage);
  ev.data.raw32.d[1] := byte(aMessage shr 8);
  ev.data.raw32.d[2] := byte(aMessage shr 16);
  ev.dest.client := FAlsaDevice.Destination.client;
  ev.dest.port := FAlsaDevice.Destination.port;
  myOk := True;
  i := snd_seq_event_output(FAlsaDevice.SeqHandle, @ev);
  if i < 0 then
    myOk := false;
  if myOk then
  begin
    i := snd_seq_drain_output(FAlsaDevice.SeqHandle);
    if i < 0 then
      myOk := false;
  end;
end;

procedure TLinuxMidiOutDevice.Close;
begin
  if FAlsaDevice.IsOpen then
  begin
    if FQueueAllocated then
    begin
      snd_seq_free_queue(FAlsaDevice.SeqHandle, FSeqQueue);
      FSeqQueue := -1;
      FQueueAllocated := False;
    end;
  end;
  FAlsaDevice.Close;
end;

function TLinuxMidiOutDevice.GetIsOpen: Boolean;
begin
  Result := FAlsaDevice.IsOpen;
end;

end.

