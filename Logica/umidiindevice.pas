unit uMidiInDevice;

interface

uses
  Classes, SysUtils,

  uMidiDevice;

type
  TMidiBuffer = array[0..31] of byte;
  TOnMidiInput = procedure(aBuffer:TMidiBuffer; size:integer) of object;

  TMidiInDevice = class(TMidiDevice)
  public
    OnMidiInput: TOnMidiInput;
  end;

implementation

end.

