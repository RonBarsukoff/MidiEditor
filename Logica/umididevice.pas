unit uMidiDevice;

interface

uses
  Classes, SysUtils;

type
  TMidiDevice = class(TObject)
  private
  protected
    FLastResult: String;
    function GetIsOpen: Boolean; virtual; abstract;
    procedure SetIsOpen(aValue: Boolean);
    procedure Open; virtual; abstract;
    procedure Close; virtual; abstract;
    function getIsOk: Boolean;
    function Readable: Boolean; virtual;
    function Writable: Boolean; virtual;
  public
    property IsOpen: Boolean read getIsOpen write setIsOpen;
    property LastResult: String read FLastResult;
    property IsOk: Boolean read getIsOk;
  end;

implementation

procedure TMidiDevice.SetIsOpen(aValue: Boolean);
begin
  if aValue <> GetIsOpen then
  begin
    if aValue then
      Open
    else
      Close;
  end;
end;

function TMidiDevice.getIsOk: Boolean;
begin
  Result := FLastResult = '';
end;

function TMidiDevice.Readable: Boolean;
begin
  Result := False;
end;

function TMidiDevice.Writable: Boolean;
begin
  Result := False;
end;

end.

