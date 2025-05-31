unit uAlsaDevice;

interface
uses
  Classes, SysUtils,

  asoundlib;

type
  TAlsaDevice = class(TObject)
  private
    FAppName: String;
  public
    SeqHandle: Psnd_seq_t;
    Client: integer;
    Sender,
    Destination: snd_seq_addr_t;
    Capabilities,
    PortType: dword;
    ClientName,
    PortName: string;
    IsOpen: Boolean;
    constructor Create(aAppName: String);
    destructor Destroy; override;
    procedure Close;
    function Writable: Boolean;
    property AppName: String read FAppName;
  end;

implementation

constructor TAlsaDevice.Create(aAppName: String);
begin
  inherited Create;
  FAppName := aAppName;
end;

destructor TAlsaDevice.Destroy;
begin
  inherited Destroy;
end;

function TAlsaDevice.Writable: Boolean;
const
  cWritable = SND_SEQ_PORT_CAP_SUBS_WRITE or SND_SEQ_PORT_CAP_WRITE; (* Both required *)
begin
  Result := (Capabilities and cWritable) = cWritable;
end;

procedure TAlsaDevice.Close;
begin
  if IsOpen then
  begin
    snd_seq_close(SeqHandle);
    SeqHandle := nil;
    IsOpen := False;
  end;
end;

end.

