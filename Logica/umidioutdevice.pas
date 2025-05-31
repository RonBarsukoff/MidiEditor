unit uMidiOutDevice;

interface

uses
  Classes, SysUtils,
    uMidiDevice;

type
  TMidiOutDevice = class(TMidiDevice)
  public
    procedure ToonAan(aKanaal, aHoogte, aVelocity: byte); virtual; abstract;
  end;

implementation

end.

