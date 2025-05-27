unit fMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Generics.Collections,

  frMidiEditor,
  fMainModel;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    lMidiStatus: TLabel;
    MainMenu1: TMainMenu;
    miBewaarAls: TMenuItem;
    miOpen: TMenuItem;
    miAfspelen: TMenuItem;
    miMidi: TMenuItem;
    miInstellingen: TMenuItem;
    miAfsluiten: TMenuItem;
    N1: TMenuItem;
    miBewaarAlsMidibestand: TMenuItem;
    miOpenMidiBestand: TMenuItem;
    miBestand: TMenuItem;
    OpenDialog1: TOpenDialog;
    pStatusBar: TPanel;
    SaveDialog1: TSaveDialog;
    pcEditors: TPageControl;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure miAfsluitenClick(Sender: TObject);
    procedure miAfspelenClick(Sender: TObject);
    procedure miBewaarAlsClick(Sender: TObject);
    procedure miBewaarAlsMidibestandClick(Sender: TObject);
    procedure miMidiClick(Sender: TObject);
    procedure miOpenClick(Sender: TObject);
    procedure miOpenMidiBestandClick(Sender: TObject);
    procedure pcEditorsChange(Sender: TObject);
  private
    FMidiEditors: TObjectList<TframeMidiEditor>;
    FHuidigeMidiEditor: TframeMidiEditor;
    FMainModel: TfrmMainModel;
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

{$R *.dfm}

{ TfrmMain }

const
  nmToonEditorBestandsFilter = 'Tonen bestand|*.tn';
  nmMidiBestandsFilter = 'Midi bestand|*.mid';

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
      miAfspelen.Caption := 'Afspelen';
    end
    else
    begin
      FHuidigeMidiEditor.Model.StartAfspelen;
      miAfspelen.Caption := 'Stop afspelen';
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

procedure TfrmMain.miBewaarAlsMidibestandClick(Sender: TObject);
begin
  if Assigned(FHuidigeMidiEditor) then
  begin
    SaveDialog1.Filter := nmMidiBestandsFilter;
    SaveDialog1.FileName := FHuidigeMidiEditor.Model.FileName;
    if SaveDialog1.Execute then
      FHuidigeMidiEditor.Model.BewaarAlsMidiBestand(SaveDialog1.FileName);
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FMainModel := TfrmMainModel.Create;
  FMainModel.Init;
  FMidiEditors := TObjectList<TframeMidiEditor>.Create(False);
  FMainModel.OnToonAfspelerStatusUpdate := handleToonAfspelerStatusUpdate;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  myEditor: TframeMidiEditor;
begin
  if CanClose then
    for myEditor in FMidiEditors do
      myEditor.Done;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FMidiEditors.Free;
  FMainModel.Free;
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
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
    OpenBestand(OpenDialog1.FileName);
end;

procedure TfrmMain.pcEditorsChange(Sender: TObject);
begin
  if pcEditors.TabIndex < 0 then
    FHuidigeMidiEditor := nil
  else
    FHuidigeMidiEditor := FMidiEditors[pcEditors.TabIndex];
end;

procedure TfrmMain.handleToonAfspelerStatusUpdate(aOk: Boolean; const aMelding: String);
begin
  if FMainModel.ToonAfspelerOk then
    lMidiStatus.Caption := 'Midi ok'
  else
    lMidiStatus.Caption := FMainModel.ToonAfspelerMelding;
end;

procedure TfrmMain.OpenMidiBestand(const aFilename: String);
var
  F: TfrmLeesMidifile;
  myMidiEditor: TframeMidiEditor;
  myTabSheet: TTabSheet;
begin
  F := TfrmLeesMidifile.Create(Self);
  try
    F.Lees(aFileName);
    if F.ShowModal = mrOK then
    begin
      myTabSheet := TTabSheet.Create(pcEditors);
      myTabSheet.PageControl := pcEditors;
      myMidiEditor := TframeMidiEditor.Create(Self);
      myMidiEditor.Name := '';
      myMidiEditor.Parent := myTabSheet;
      FMidiEditors.Add(myMidiEditor);
      myMidiEditor.Init(aFileName, FMainModel);
      F.VulTonenObject(myMidiEditor.Model.TonenObject);
      myMidiEditor.VulInfoTab;
      pcEditors.ActivePage := myTabSheet;
      pcEditorsChange(nil);
      ZetTabCaption;
    end;
  finally
    F.Free;
  end;
end;

procedure TfrmMain.OpenBestand(const aFilename: String);
var
  myMidiEditor: TframeMidiEditor;
  myTabSheet: TTabSheet;
begin
  myTabSheet := TTabSheet.Create(pcEditors);
  myTabSheet.PageControl := pcEditors;
  myMidiEditor := TframeMidiEditor.Create(Self);
  myMidiEditor.Name := '';
  myMidiEditor.Parent := myTabSheet;
  FMidiEditors.Add(myMidiEditor);
  myMidiEditor.Init(aFileName, FMainModel);
  myMidiEditor.Model.OpenBestand(aFileName);
  myMidiEditor.VulInfoTab;
  pcEditors.ActivePage := myTabSheet;
  pcEditorsChange(nil);
  ZetTabCaption;
end;

procedure TfrmMain.ZetTabCaption;
begin
  if Assigned(FHuidigeMidiEditor) then
    pcEditors.ActivePage.Caption := ExtractFileName(FHuidigeMidiEditor.Model.FileName);
end;

end.
