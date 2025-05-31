program MidiEditorLazarus;

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, fMain, fMidiDialog, cmpAfspeelThread, cmpToonInspeler, cmpAfspeler,
  cmpAfspeelevent, cmpAfspeellijst, uTypes, fLeesMidifile, frMidiEditor,
  fLeesMidifilemodel, fMainModel, uProcs, uMMProcs, fToonEditormodel, cmpShapes,
  cmpTrackElement, cmpTonenObject, cmpVolumeChange, cmpPedaal,
  cmpTempowisseling, cmpPanoramaChange, cmpProgramChange, cmpEventShapes, 
cmpObjectInfo, frObjectinfo, cmpStrings2D, fGeselecteerdeMoment,
uMidiDeviceFactory, uMidiInDevice, uMidiDevice, uMidiOutDevice, 
uLinuxMidiInspeelThread;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

