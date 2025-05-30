unit uWindowsMidiInDevice;

{$mode Delphi}

interface

uses
  Classes, SysUtils,

  uMidiInDevice;

type
  TWindowsMidiInDevice = class(TMidiInDevice)
  private
  protected
    procedure Open; override;
    procedure Close; override;
    function GetIsOpen: Boolean; override;
  public
    (*    OnMidiInput: TOnMidiInput;
    constructor Create(aAppName: String);
    destructor Destroy; override;
    procedure Init(aSeqHandle: Psnd_seq_t; aPortInfo: Psnd_seq_port_info_t;
      aClientinfo: Psnd_seq_client_info_t);
    procedure GetMidiInEvents; *)
  end;

implementation

procedure TWindowsMidiInDevice.Open;
begin

end;

procedure TWindowsMidiInDevice.Close;
begin

end;

function TWindowsMidiInDevice.GetIsOpen: Boolean;
begin

end;

end.

