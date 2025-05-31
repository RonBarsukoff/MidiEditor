unit uMidiInDevice;

interface

uses
  Classes, SysUtils,

  uMidiDevice,
  uCommonTypes;

type
  TMidiInDevice = class(TMidiDevice)
  public
    OnToonEvent: TToonInEvent;
  end;

implementation

end.

