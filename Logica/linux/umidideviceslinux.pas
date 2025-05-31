unit uMidiDevicesLinux;

interface

uses
  Classes,
  uMidiDevices;

type
  TMidiDevicesLinux = class(TMidiDevices)
  private
    procedure Warning(aMessage: String);
  public
    procedure LeesInDevices; override;
    procedure LeesOutDevices; override;
  end;

implementation

uses
  SysUtils,

  asoundlib,
  uLinuxMidiInDevice,
  uLinuxMidiOutDevice;

procedure TMidiDevicesLinux.LeesInDevices;
var
  myStatus: integer;
  myClientinfo: Psnd_seq_client_info_t;
  myPortInfo: Psnd_seq_port_info_t;
  myCurrentClient: integer;
  mySelectedDevice: TLinuxMidiInDevice;
  mySeqHandle: Psnd_seq_t;
  myCapabilities,
  myPortType: DWord;
  myClientName: String;
const
  cReadable = SND_SEQ_PORT_CAP_SUBS_READ or SND_SEQ_PORT_CAP_READ or SND_SEQ_PORT_CAP_SYNC_READ; (* All required *)
begin
  ClearMidiInDevices;
  myStatus := snd_seq_open(@mySeqHandle, 'default', SND_SEQ_OPEN_INPUT, 0);
  if myStatus < 0 then
    Warning('Cannot open sequencer for ALSA device enumeration: ' + snd_strError(myStatus))
  else
    try
      snd_seq_client_info_malloc(@myClientinfo);
      try
        snd_seq_client_info_set_client(myClientinfo, -1);
        while snd_seq_query_next_client(mySeqHandle, myClientinfo) >= 0 do
        begin
          myCurrentClient := snd_seq_client_info_get_client(myClientinfo);
          snd_seq_port_info_malloc(@myPortInfo);
          try
            snd_seq_port_info_set_client(myPortInfo, myCurrentClient);
            snd_seq_port_info_set_port(myPortInfo, -1);
            while (snd_seq_query_next_port(mySeqHandle, myPortInfo) >= 0) do
            begin
              myPortType := snd_seq_port_info_get_type(myPortInfo);
              myCapabilities := snd_seq_port_info_get_capability(myPortinfo);
              if (myPortType <> 0)
              and ((myCapabilities and cReadable) = cReadable) then
              begin
                mySelectedDevice := TLinuxMidiInDevice.Create('MidiEditor');
                mySelectedDevice.Init(mySeqHandle, myPortinfo, myClientInfo);
                myClientName := snd_seq_client_info_get_name(myClientInfo);
                fInDeviceList.AddObject(myClientName, mySelectedDevice)
              end;
            end { while }
          finally
            snd_seq_port_info_free(myPortInfo);
          end
        end
      finally
        snd_seq_client_info_free(myClientInfo);
      end;
    finally
      snd_seq_close(mySeqHandle);
    end;
end;

procedure TMidiDevicesLinux.LeesOutDevices;
var
  myStatus: integer;
  myClientinfo: Psnd_seq_client_info_t;
  myPortInfo: Psnd_seq_port_info_t;
  myCurrentClient: integer;
  mySelectedDevice: TLinuxMidiOutDevice;
  mySeqHandle: Psnd_seq_t;
  myCapabilities,
  myPortType: DWord;
  myClientName,
  myPortName: String;
const
  cSynthesizer= SND_SEQ_PORT_TYPE_SYNTHESIZER or SND_SEQ_PORT_TYPE_PORT; (* Either required *)
  cWritable = SND_SEQ_PORT_CAP_SUBS_WRITE or SND_SEQ_PORT_CAP_WRITE; (* Both required *)
begin
  ClearMidiOutDevices;

  (* Open the MIDI sequencer in order to enumerate a list of devices. Start off   *)
  (* with a check that the ALSA interface library is accessible, if this fails    *)
  (* (which since the program has started implies a missing shared-object         *)
  (* library) fail gracefully.                                                    *)

//  myStatus := snd_seq_open(@mySeqHandle, 'default', SND_SEQ_OPEN_DUPLEX, 0);
  myStatus := snd_seq_open(@mySeqHandle, 'default', SND_SEQ_OPEN_OUTPUT, 0);
  if myStatus < 0 then
    Warning('Cannot open sequencer for ALSA device enumeration: ' + snd_strError(myStatus))
  else
    try
      snd_seq_client_info_malloc(@myClientinfo);
      try
        snd_seq_client_info_set_client(myClientinfo, -1);
        while snd_seq_query_next_client(mySeqHandle, myClientinfo) >= 0 do
        begin
          myCurrentClient := snd_seq_client_info_get_client(myClientinfo);
          snd_seq_port_info_malloc(@myPortInfo);
          try
            snd_seq_port_info_set_client(myPortInfo, myCurrentClient);
            snd_seq_port_info_set_port(myPortInfo, -1);
            while (snd_seq_query_next_port(mySeqHandle, myPortInfo) >= 0) do
            begin
              myCapabilities := snd_seq_port_info_get_capability(myPortinfo);
              myPortType := snd_seq_port_info_get_type(myPortInfo);
              myPortName := snd_seq_port_info_get_name(myPortInfo);
              if ((myCapaBilities and cWritable) = cWritable)
              and ((myPortType and cSynthesizer) <> 0)
              and (Pos('through', LowerCase(myPortName)) < 1) then
              begin
                mySelectedDevice := TLinuxMidiOutDevice.Create('MidiEditor');
                mySelectedDevice.Init(mySeqHandle, myPortinfo, myClientInfo);
                myClientName := snd_seq_client_info_get_name(myClientInfo);
                fOutDeviceList.AddObject(myClientname, mySelectedDevice);
              end;
            end { while }
          finally
            snd_seq_port_info_free(myPortInfo);
          end
        end
      finally
        snd_seq_client_info_free(myClientInfo);
      end;
    finally
      snd_seq_close(mySeqHandle);
    end;
end;

procedure TMidiDevicesLinux.Warning(aMessage: String);
begin
  writeln(aMessage);
end;

end.

