unit uMidiOutDevice;

interface

uses
  Classes, SysUtils,
    uMidiDevice;

type
  TMidiOutDevice = class(TMidiDevice)
  public
    procedure ToonAan(aKanaal, aHoogte, aVelocity: byte); virtual; abstract;
    procedure SendShortMessage(aMessage: LongInt); virtual; abstract;
  end;

implementation

end.

