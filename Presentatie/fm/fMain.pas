unit fMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Menus,
  FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Memo, FMX.Layouts, FMX.ListBox, FMX.StdCtrls, FMX.TabControl,
  Generics.Collections,

  frMidiEditor,
  fMainModel;

type
  TfrmMain = class(TForm)
    lMidiStatus: TLabel;
    MenuBar1: TMenuBar;
    miMidi: TMenuItem;
    miInstellingen: TMenuItem;
    miAfsluiten: TMenuItem;
    N1: TMenuItem;
    miBewaarAlsMidiBestand: TMenuItem;
    miOpenMidiBestand: TMenuItem;
    miBestand: TMenuItem;
    OpenDialog1: TOpenDialog;
    pStatusBar: TPanel;
    SaveDialog1: TSaveDialog;
    pcEditors: TTabControl;
    miAfspelen: TMenuItem;
    miOpen: TMenuItem;
    miBewaarAls: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; 
      Shift: TShiftState);
    procedure miAfsluitenClick(Sender: TObject);
    procedure miBewaarAlsMidiBestandClick(Sender: TObject);
    procedure miMidiClick(Sender: TObject);
    procedure miOpenMidiBestandClick(Sender: TObject);
    procedure pcEditorsChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure miAfspelenClick(Sender: TObject);
    procedure miBewaarAlsClick(Sender: TObject);
    procedure miOpenClick(Sender: TObject);
  private
    FMidiEditors: TObjectList<TframeMidiEditor>;
    FHuidigeMidiEditor: TframeMidiEditor;
    FMainModel: TfrmMainModel;
    FBezigMetOpenen: Boolean;
    procedure handleToonAfspelerStatusUpdate(aOk: Boolean; const aMelding: String);
    procedure OpenMidiBestand(const aFilename: String);
    procedure OpenBestand(const aFilename: String);
    procedure ZetTabCaption;
  public

  end;

var
  frmMain: TfrmMain;

implementation
uses
  uInstellingen,
  fLeesMidifile,
  fMidiDialog;

{$R *.fmx}

const
  nmToonEditorBestandsFilter = 'Tonen bestand|*.tn';
  nmMidiBestandsFilter = 'Midi bestand|*.mid';

{ TfrmMain }

procedure TfrmMain.miAfsluitenClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.miAfspelenClick(Sender: TObject);
begin
  if Assigned(FHuidigeMidiEditor) then
  begin
    if FHuidigeMidiEditor.Model.AfspelenGestart then
    begin
      FHuidigeMidiEditor.Model.StopAfspelen;
      miAfspelen.Text := 'Afspelen';
    end
    else
    begin
      FHuidigeMidiEditor.Model.StartAfspelen;
      miAfspelen.Text := 'Stop afspelen';
    end;
  end;
end;

procedure TfrmMain.miBewaarAlsClick(Sender: TObject);
begin
  if Assigned(FHuidigeMidiEditor) then
  begin
    SaveDialog1.Filter := nmToonEditorBestandsFilter;
    SaveDialog1.FileName := FHuidigeMidiEditor.Model.FileName;
    if SaveDialog1.Execute then
    begin
      FHuidigeMidiEditor.Model.BewaarAls(SaveDialog1.FileName);
      ZetTabCaption;
    end;
  end;
end;

procedure TfrmMain.miBewaarAlsMidiBestandClick(Sender: TObject);
begin
  if Assigned(FHuidigeMidiEditor) then
  begin
    SaveDialog1.Filter := nmMidiBestandsFilter;
    SaveDialog1.FileName := FHuidigeMidiEditor.Model.FileName;
    if SaveDialog1.Execute then
    begin
      FHuidigeMidiEditor.Model.BewaarAlsMidiBestand(SaveDialog1.FileName);
      ZetTabCaption;
    end;
  end;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  myEditor: TframeMidiEditor;
begin
  if CanClose then
    for myEditor in FMidiEditors do
      myEditor.Done;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FMainModel := TfrmMainModel.Create;
  FMainModel.Init;
  FMidiEditors := TObjectList<TframeMidiEditor>.Create(False);
  FMainModel.OnToonAfspelerStatusUpdate := handleToonAfspelerStatusUpdate;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FMidiEditors.Free;
  FMainModel.Free;
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Assigned(FHuidigeMidiEditor) then
    FHuidigeMidiEditor.HandleKeyDown(Key, Shift);
end;

procedure TfrmMain.miMidiClick(Sender: TObject);
var
  F: TfrmMidiDialog;
begin
  F := TfrmMidiDialog.Create(Self);
  try
    F.Init(FMainModel.ToonAfspeler, FMainModel.ToonInspeler);
    F.MidiInDevice := FMainModel.Instellingen.MidiInDevice;
    F.MidiOutDevice := FMainModel.Instellingen.MidiOutDevice;
    if F.ShowModal = mrOK then
    begin
      FMainModel.Instellingen.MidiInDevice := F.MidiInDevice;
      FMainModel.Instellingen.MidiOutDevice := F.MidiOutDevice;
      FMainModel.BewaarMidiInstellingen;
    end;
  finally
    F.Free;
  end;
end;

procedure TfrmMain.miOpenClick(Sender: TObject);
begin
  OpenDialog1.Filter := nmToonEditorBestandsFilter;
  if OpenDialog1.Execute then
    OpenBestand(OpenDialog1.FileName);
end;

procedure TfrmMain.miOpenMidiBestandClick(Sender: TObject);
begin
  OpenDialog1.Filter := nmMidiBestandsFilter;
  if OpenDialog1.Execute then
    OpenMidiBestand(OpenDialog1.FileName);
end;

procedure TfrmMain.pcEditorsChange(Sender: TObject);
begin
  if not FBezigMetOpenen then
  begin
    if pcEditors.TabIndex < 0 then
      FHuidigeMidiEditor := nil
    else
      FHuidigeMidiEditor := FMidiEditors[pcEditors.TabIndex];
  end;
end;

procedure TfrmMain.handleToonAfspelerStatusUpdate(aOk: Boolean; const aMelding: String);
begin
  if FMainModel.ToonAfspelerOk then
    lMidiStatus.Text := 'Midi ok'
  else
    lMidiStatus.Text := FMainModel.ToonAfspelerMelding;
end;

procedure TfrmMain.OpenMidiBestand(const aFilename: String);
var
  F: TfrmLeesMidifile;
  myMidiEditor: TframeMidiEditor;
  myTabSheet: TTabItem;
begin
  F := TfrmLeesMidifile.Create(Self);
  try
    F.Lees(aFileName);
    if F.ShowModal = mrOK then
    begin
      FBezigMetOpenen := True;
      try
        myTabSheet := pcEditors.Add(TTabItem) as TTabItem;
        myMidiEditor := TframeMidiEditor.Create(Self);
        myMidiEditor.Name := '';
        myMidiEditor.Parent := myTabSheet;
        FMidiEditors.Add(myMidiEditor);
        myMidiEditor.Init(aFileName, FMainModel);
        F.VulTonenObject(myMidiEditor.Model.TonenObject);
        myMidiEditor.VulInfoTab;
        pcEditors.ActiveTab := myTabSheet;
      finally
        FBezigMetOpenen := False;
        pcEditorsChange(nil);
        ZetTabCaption;
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure TfrmMain.OpenBestand(const aFilename: String);
var
  myMidiEditor: TframeMidiEditor;
  myTabSheet: TTabItem;
begin
  FBezigMetOpenen := True;
  try
    myTabSheet := pcEditors.Add(TTabItem) as TTabItem;
    myMidiEditor := TframeMidiEditor.Create(Self);
    myMidiEditor.Name := '';
    myMidiEditor.Parent := myTabSheet;
    FMidiEditors.Add(myMidiEditor);
    myMidiEditor.Init(aFileName, FMainModel);
    myMidiEditor.Model.OpenBestand(aFileName);
    myMidiEditor.VulInfoTab;
    pcEditors.ActiveTab := myTabSheet;
  finally
    FBezigMetOpenen := False;
    pcEditorsChange(nil);
    ZetTabCaption;
  end;
end;

procedure TfrmMain.ZetTabCaption;
begin
  if Assigned(FHuidigeMidiEditor) then
    pcEditors.ActiveTab.Text := ExtractFileName(FHuidigeMidiEditor.Model.FileName);
end;

end.
