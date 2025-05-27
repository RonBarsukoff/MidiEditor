unit uMMProcs;

interface

uses
  Classes, SysUtils,
  uTypes
  {$ifdef Windows}
  ,MMSystem
  {$endif}
  ;

type

{$ifndef Windows}
  PHMIDIOUT = ^THandle;
  PHMIDIIN = ^THandle;
  MMRESULT  = UINT;
  HMIDIIN = THandle;
  HMIDIOUT = THandle;

  TMidiInCaps = packed Record
                         wMid: WORD;
                         wPid: WORD;
                         vDriverVersion: UINT;
                         szPname: array [0..Pred(32)] Of CHAR;
                         dwSupport: DWORD;
  		End;
  PMidiInCaps = ^TMidiInCaps;
  TMidiOutCaps = packed Record
                           wMid: WORD;
                           wPid: WORD;
                           vDriverVersion: UINT;
                           szPname: array [0..Pred(32)] Of CHAR;
                           wTechnology: WORD;
                           wVoices: WORD;
                           wNotes: WORD;
                           wChannelMask: WORD;
                           dwSupport: DWORD;
			End;
  PMidiOutCaps = ^TMidiOutCaps;
  TFNTimeCallBack = Procedure (uTimerID, uMsg: UINT; dwUser, dw1, dw2: QWord);stdcall;
{$else}
  PHMIDIOUT = MMSystem.PHMIDIOUT;
  MMRESULT  = MMSystem.MMRESULT;
  HMIDIIN = MMSystem.HMIDIIN;
  HMIDIOUT = MMSystem.HMIDIOUT;

  TMidiInCaps = MMSystem.TMidiInCaps;
  TMidiOutCaps = MMSystem.TMidiOutCaps;
  TFNTimeCallBack = MMSystem.TFNTimeCallBack;
{$endif}

const
  midi_mapper = UINT(-1);  //MMSystem.midi_mapper;

  CALLBACK_NULL = 0;
  CALLBACK_EVENT = $50000;
  CALLBACK_WINDOW = $10000;
  CALLBACK_TASK = $20000;
  CALLBACK_THREAD = CALLBACK_TASK;
  CALLBACK_FUNCTION = $30000;

  MMSYSERR_BASE = 0;
  MMSYSERR_NOERROR = 0;
  MMSYSERR_ERROR = (MMSYSERR_BASE+1);
  MMSYSERR_BADDEVICEID = (MMSYSERR_BASE+2);
  MMSYSERR_NOTENABLED = (MMSYSERR_BASE+3);
  MMSYSERR_ALLOCATED = (MMSYSERR_BASE+4);
  MMSYSERR_INVALHANDLE = (MMSYSERR_BASE+5);
  MMSYSERR_NODRIVER = (MMSYSERR_BASE+6);
  MMSYSERR_NOMEM = (MMSYSERR_BASE+7);
  MMSYSERR_NOTSUPPORTED = (MMSYSERR_BASE+8);
  MMSYSERR_BADERRNUM = (MMSYSERR_BASE+9);
  MMSYSERR_INVALFLAG = (MMSYSERR_BASE+10);
  MMSYSERR_INVALPARAM = (MMSYSERR_BASE+11);
  MMSYSERR_HANDLEBUSY = (MMSYSERR_BASE+12);
  MMSYSERR_INVALIDALIAS = (MMSYSERR_BASE+13);
  MMSYSERR_BADDB = (MMSYSERR_BASE+14);
  MMSYSERR_KEYNOTFOUND = (MMSYSERR_BASE+15);
  MMSYSERR_READERROR = (MMSYSERR_BASE+16);
  MMSYSERR_WRITEERROR = (MMSYSERR_BASE+17);
  MMSYSERR_DELETEERROR = (MMSYSERR_BASE+18);
  MMSYSERR_VALNOTFOUND = (MMSYSERR_BASE+19);
  MMSYSERR_NODRIVERCB = (MMSYSERR_BASE+20);
  MMSYSERR_LASTERROR = (MMSYSERR_BASE+20);

  TIME_ONESHOT = 0;
  TIME_PERIODIC = 1;

  MM_MIM_OPEN = $3C1;
  MM_MIM_CLOSE = $3C2;
  MM_MIM_DATA = $3C3;
  MM_MIM_LONGDATA = $3C4;
  MM_MIM_ERROR = $3C5;
  MM_MIM_LONGERROR = $3C6;

  MIM_DATA = MM_MIM_DATA;
  MIM_LONGDATA = MM_MIM_LONGDATA;
  MIM_ERROR = MM_MIM_ERROR;
  MIM_LONGERROR = MM_MIM_LONGERROR;

function midiOutOpen(lphMidiOut: PHMIDIOUT; uDeviceID: UINT; dwCallback, dwInstance: DWORD_PTR; dwFlags: DWORD): MMRESULT;
Function midiOutClose(x1: HMIDIOUT): MMRESULT;
Function midiOutShortMsg(x1: HMIDIOUT; x2: DWORD): MMRESULT;
Function timeGetTime: DWORD;stdcall;
function timeSetEvent(uDelay, uResolution: UINT; lpFunction: TFNTimeCallBack; dwUser: DWORD_PTR; uFlags: UINT): MMRESULT;
Function timeKillEvent(x1: UINT): MMRESULT;
function midiInOpen(lphMidiIn: PHMIDIIN; uDeviceID: UINT; dwCallback, dwInstance: DWORD_PTR; dwFlags: DWORD): MMRESULT;
Function midiInClose(x1: HMIDIIN): MMRESULT;
Function midiInStart(x1: HMIDIIN): MMRESULT;
Function midiInStop(x1: HMIDIIN): MMRESULT;
function midiInGetNumDevs: UINT;
function midiInGetDevCaps(DeviceID: UIntPtr; lpCaps: PMidiInCaps; uSize: UINT): MMRESULT;
function midiOutGetNumDevs: UINT;
function midiOutGetDevCaps(uDeviceID: UIntPtr; lpCaps: PMidiOutCaps; uSize: UINT): MMRESULT;

implementation

{$ifdef Windows}
function midiOutOpen(lphMidiOut: PHMIDIOUT; uDeviceID: UINT; dwCallback, dwInstance: DWORD_PTR; dwFlags: DWORD): MMRESULT;
begin
  Result := MMSystem.midiOutOpen(lphMidiOut, uDeviceID, dwCallback, dwInstance, dwFlags);
end;

Function midiOutClose(x1: HMIDIOUT): MMRESULT;
begin
  Result := MMSystem.midiOutClose(x1);
end;

Function midiOutShortMsg(x1: HMIDIOUT; x2: DWORD): MMRESULT;
begin
  Result := MMSystem.midiOutShortMsg(x1, x2);
end;

Function timeGetTime: DWORD;
begin
  Result := MMSystem.timeGetTime;
end;

function timeSetEvent(uDelay, uResolution: UINT; lpFunction: TFNTimeCallBack; dwUser: DWORD_PTR; uFlags: UINT): MMRESULT;
begin
  Result := MMSystem.timeSetEvent(uDelay, uResolution, lpFunction, dwUser, uFlags);
end;

Function timeKillEvent(x1: UINT): MMRESULT;
begin
  Result := MMSystem.timeKillEvent(x1);
end;

function midiInOpen(lphMidiIn: PHMIDIIN; uDeviceID: UINT; dwCallback, dwInstance: DWORD_PTR; dwFlags: DWORD): MMRESULT;
begin
  Result := MMSystem.midiInOpen(lphMidiIn, uDeviceID, dwCallback, dwInstance, dwFlags);
end;

Function midiInClose(x1: HMIDIIN): MMRESULT;
begin
  Result := MMSystem.midiInClose(x1);
end;

Function midiInStart(x1: HMIDIIN): MMRESULT;
begin
  Result := MMSystem.midiInStart(x1);
end;

Function midiInStop(x1: HMIDIIN): MMRESULT;
begin
  Result := MMSystem.midiInStop(x1);
end;

function midiInGetNumDevs: UINT;
begin
  Result := MMSystem.midiInGetNumDevs;
end;

function midiInGetDevCaps(DeviceID: UIntPtr; lpCaps: PMidiInCaps; uSize: UINT): MMRESULT;
begin
  Result := MMSystem.midiInGetDevCaps(DeviceID, lpCaps, uSize);
end;

function midiOutGetNumDevs: UINT;
begin
  Result := MMSystem.midiOutGetNumDevs;
end;

function midiOutGetDevCaps(uDeviceID: UIntPtr; lpCaps: PMidiOutCaps; uSize: UINT): MMRESULT;
begin
  Result := MMSystem.midiOutGetDevCaps(uDeviceID, lpCaps, uSize);
end;

{$else}

function midiOutOpen(lphMidiOut: PHMIDIOUT; uDeviceID: UINT; dwCallback, dwInstance: DWORD_PTR; dwFlags: DWORD): MMRESULT;
begin
  Result := MMSYSERR_ERROR;
end;

Function midiOutClose(x1: HMIDIOUT): MMRESULT;
begin
  Result := MMSYSERR_ERROR;
end;

Function midiOutShortMsg(x1: HMIDIOUT; x2: DWORD): MMRESULT;
begin
  Result := MMSYSERR_ERROR;
end;

Function timeGetTime: DWORD;stdcall;
begin
  Result := MMSYSERR_ERROR;
end;

function timeSetEvent(uDelay, uResolution: UINT; lpFunction: TFNTimeCallBack; dwUser: DWORD_PTR; uFlags: UINT): MMRESULT;
begin
  Result := MMSYSERR_ERROR;
end;

Function timeKillEvent(x1: UINT): MMRESULT;
begin
  Result := MMSYSERR_ERROR;
end;

function midiInOpen(lphMidiIn: PHMIDIIN; uDeviceID: UINT; dwCallback, dwInstance: DWORD_PTR; dwFlags: DWORD): MMRESULT;
begin
  Result := MMSYSERR_ERROR;
end;

Function midiInClose(x1: HMIDIIN): MMRESULT;
begin
  Result := MMSYSERR_ERROR;
end;

Function midiInStart(x1: HMIDIIN): MMRESULT;
begin
  Result := MMSYSERR_ERROR;
end;

Function midiInStop(x1: HMIDIIN): MMRESULT;
begin
  Result := MMSYSERR_ERROR;
end;

function midiInGetNumDevs: UINT;
begin
  Result := MMSYSERR_ERROR;
end;

function midiInGetDevCaps(DeviceID: UIntPtr; lpCaps: PMidiInCaps; uSize: UINT): MMRESULT;
begin
  Result := MMSYSERR_ERROR;
end;

function midiOutGetNumDevs: UINT;
begin
  Result := MMSYSERR_ERROR;
end;

function midiOutGetDevCaps(uDeviceID: UIntPtr; lpCaps: PMidiOutCaps; uSize: UINT): MMRESULT;
begin
  Result := MMSYSERR_ERROR;
end;

{$endif}
end.

