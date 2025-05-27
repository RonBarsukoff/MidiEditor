unit uMidi;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,

  asoundlib,
  ualsadevice,
  uMidiInDevice,
  uMidiOutDevice;

type
  TMidi = class(TObject)
  private
    FOutDeviceList: TStringList;
    FInDeviceList: TStringList;
    procedure ClearMidiOutDevices;
    procedure ClearMidiInDevices;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Init;
    procedure LeesMidiOutDevices;
    procedure LeesMidiInDevices;
    property OutDeviceList: TStringList read FOutDeviceList;
    property InDeviceList: TStringList read FInDeviceList;
  end;


implementation
uses
  uGlobals;

constructor TMidi.Create;
begin
  inherited Create;
  FOutDeviceList := TStringList.Create;
  FInDeviceList := TStringList.Create;
end;

destructor TMidi.Destroy;
begin
  ClearMidiOutDevices;
  FOutDeviceList.Free;
  ClearMidiInDevices;
  FInDeviceList.Free;
  inherited Destroy;
end;

procedure TMidi.Init;
begin
  LeesMidiOutDevices;
  LeesMidiInDevices;
end;

procedure TMidi.LeesMidiOutDevices;
var
  myStatus: integer;
  myClientinfo: Psnd_seq_client_info_t;
  myPortInfo: Psnd_seq_port_info_t;
  myCurrentClient: integer;
  mySelectedDevice: TMidiOutDevice;
  mySeqHandle: Psnd_seq_t;
  const
    cSynthesizer= SND_SEQ_PORT_TYPE_SYNTHESIZER { or SND_SEQ_PORT_TYPE_PORT } ; (* Either required *)
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
              mySelectedDevice := TMidiOutDevice.Create;
              mySelectedDevice.Init(mySeqHandle, myPortinfo, myClientInfo);
              if mySelectedDevice.AlsaDevice.Writable
              and ((mySelectedDevice.AlsaDevice.portType and cSynthesizer) <> 0) then
              begin
                fOutDeviceList.AddObject(mySelectedDevice.AlsaDevice.Clientname, mySelectedDevice);
                mySelectedDevice := nil   (* Object is in list                    *)
              end
              else
              begin
                Warning(Format('%s is geen outputdevice', [mySelectedDevice.AlsaDevice.Clientname]));
                mySelectedDevice.Free;
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

procedure TMidi.LeesMidiInDevices;
var
  myStatus: integer;
  myClientinfo: Psnd_seq_client_info_t;
  myPortInfo: Psnd_seq_port_info_t;
  myCurrentClient: integer;
  mySelectedDevice: TMidiInDevice;
  mySeqHandle: Psnd_seq_t;
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
              mySelectedDevice := TMidiInDevice.Create;
              mySelectedDevice.Init(mySeqHandle, myPortinfo, myClientInfo);
              if (mySelectedDevice.AlsaDevice.PortType = 0)
              or not mySelectedDevice.AlsaDevice.Readable then
                mySelectedDevice.Free
              else
                fInDeviceList.AddObject(mySelectedDevice.AlsaDevice.ClientName, mySelectedDevice)
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

procedure TMidi.ClearMidiOutDevices;
var
  I: Integer;
begin
  for I := 0 to FOutDeviceList.Count-1 do
    FOutDeviceList.Objects[I].Free;
  FOutDeviceList.Clear;
end;

procedure TMidi.ClearMidiInDevices;
var
  I: Integer;
begin
  for I := 0 to FInDeviceList.Count-1 do
    FInDeviceList.Objects[I].Free;
  FInDeviceList.Clear;
end;

end.

