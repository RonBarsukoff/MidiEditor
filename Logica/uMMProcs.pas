unit uMMProcs;

interface

uses
  Classes, SysUtils, MMSystem;

function MMResultString(aMMResult: Integer): String;


implementation

function MMResultString(aMMResult: Integer): String;
begin
  case aMMResult of
    MMSYSERR_NOERROR: Result := 'Ok';
    MMSYSERR_ERROR: Result := 'unspecified error';
    MMSYSERR_BADDEVICEID: Result := 'device ID out of range';
    MMSYSERR_NOTENABLED: Result := 'driver failed enable';
    MMSYSERR_ALLOCATED: Result := 'device already allocated';
    MMSYSERR_INVALHANDLE: Result := 'device handle is invalid';
    MMSYSERR_NODRIVER: Result := 'no device driver present';
    MMSYSERR_NOMEM: Result := 'memory allocation error';
    MMSYSERR_NOTSUPPORTED: Result := 'function is not supported';
    MMSYSERR_BADERRNUM: Result := 'error value out of range';
    MMSYSERR_INVALFLAG: Result := 'invalid flag passed';
    MMSYSERR_INVALPARAM: Result := 'invalid parameter passed';
    MMSYSERR_HANDLEBUSY: Result := 'handle being used simultaneously on another thread (eg callback)';
    MMSYSERR_INVALIDALIAS: Result := 'specified alias not found';
    MMSYSERR_BADDB: Result := 'bad registry database';
    MMSYSERR_KEYNOTFOUND: Result := 'registry key not found';
    MMSYSERR_READERROR: Result := 'registry read error';
    MMSYSERR_WRITEERROR: Result := 'registry write error';
    MMSYSERR_DELETEERROR: Result := 'registry delete error';
    MMSYSERR_VALNOTFOUND: Result := 'registry value not found';
    MMSYSERR_NODRIVERCB: Result := 'driver does not call DriverCallback';
    MMSYSERR_BASE + 21 {MMSYSERR_MOREDATA niet beschikbaar in fpc}: Result := 'more data to be returned';
  end;
end;

end.

