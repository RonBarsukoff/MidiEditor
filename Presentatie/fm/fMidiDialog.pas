unit fMidiDialog;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox,
  uCommonTypes,
  fMidiDialogModel,
  cmpToonAfspeler,
  cmpToonInspeler;

type
  TfrmMidiDialog = class(TForm)
    bCancel: TButton;
    bOk: TButton;
    cbMidiInDevices: TComboBox;
    cbMidiOutDevices: TComboBox;
    bTestMidiOut: TSpeedButton;
    cbTestMidiIn: TCheckBox;
    lMelding: TLabel;
    lIngespeeldeToon: TLabel;
    lMidiInDevice: TLabel;
    lMidiOutDevice: TLabel;
    Timer1: TTimer;
    procedure cbTestMidiInChange(Sender: TObject);
    procedure bTestMidiOutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FModel: TfrmMidiDialogModel;
    FInMidiInClick: Boolean;
    procedure setMidiInDevice(aValue : String);
    procedure setMidiOutDevice(aValue: String);
    function getMidiInDevice: String;
    function getMidiOutDevice: String;
    procedure HandleToonEvent(aToon: TAfspeelToon);
    procedure HandleMidiInStatusUpdate(aOk: Boolean; const aMelding: String);
  public
    procedure Init(aToonAfspeler: TToonAfspeler; aToonInspeler: TToonInspeler);
    property MidiInDevice: String read getMidiInDevice write setMidiInDevice;
    property MidiOutDevice: String read getMidiOutDevice write setMidiOutDevice;
  end;

implementation

{$R *.fmx}

procedure TfrmMidiDialog.Init(aToonAfspeler: TToonAfspeler; aToonInspeler: TToonInspeler);
begin
  FModel.Init(aToonAfspeler, aToonInspeler);
  aToonInspeler.OnStatusUpdate := HandleMidiInStatusUpdate;
  FModel.LeesInDevices(cbMidiInDevices.Items);
  FModel.LeesOutDevices(cbMidiOutDevices.Items);
  cbMidiInDevices.Enabled := cbMidiInDevices.Items.Count > 0;
  cbMidiOutDevices.Enabled := cbMidiOutDevices.Items.Count > 0;
end;

procedure TfrmMidiDialog.bTestMidiOutClick(Sender: TObject);
begin
  if bTestMidiOut.IsPressed then
  begin
    FModel.TestMidiOut(true, getMidiOutDevice);
    Timer1.Enabled := True;
  end
  else
  begin
    Timer1.Enabled := False;
    FModel.TestMidiOut(False);
  end;
end;

procedure TfrmMidiDialog.cbTestMidiInChange(Sender: TObject);
begin
  if not FInMidiInClick then
  begin
    try
      FInMidiInClick := True;
      FModel.TestMidiIn(cbTestMidiIn.IsChecked, getMidiInDevice);
    finally
      FInMidiInClick := False;
    end;
  end;
end;

procedure TfrmMidiDialog.FormCreate(Sender: TObject);
begin
  FModel := TfrmMidiDialogModel.Create;
  FModel.OnToonEvent := HandleToonEvent;
end;

procedure TfrmMidiDialog.FormDestroy(Sender: TObject);
begin
  Timer1.Enabled := False;
  FModel.Free;
end;

procedure TfrmMidiDialog.Timer1Timer(Sender: TObject);
begin
  FModel.VolgendeToon;
end;

procedure TfrmMidiDialog.setMidiInDevice(aValue: String);
begin
  cbMidiInDevices.ItemIndex := cbMidiInDevices.Items.IndexOf(aValue);
end;

procedure TfrmMidiDialog.setMidiOutDevice(aValue: String);
begin
  cbMidiOutDevices.ItemIndex := cbMidiOutDevices.Items.IndexOf(aValue);
end;

function TfrmMidiDialog.getMidiInDevice: String;
begin
  if cbMidiInDevices.ItemIndex >= 0 then
    Result := cbMidiInDevices.Items[cbMidiInDevices.ItemIndex]
  else
    Result := '';
end;

function TfrmMidiDialog.getMidiOutDevice: String;
begin
  if cbMidiOutDevices.ItemIndex >= 0 then
    Result := cbMidiOutDevices.Items[cbMidiOutDevices.ItemIndex]
  else
    Result := '';
end;

procedure TfrmMidiDialog.HandleToonEvent(aToon: TAfspeelToon);
begin
  if aToon.Aan then
    lIngespeeldeToon.Text := IntToStr(aToon.Hoogte)
  else
    lIngespeeldeToon.Text := '';
end;

procedure TfrmMidiDialog.HandleMidiInStatusUpdate(aOk: Boolean; const aMelding: String);
begin
  lMelding.Text := aMelding;
  cbTestMidiIn.IsChecked := aOK;
end;

end.
