unit fLeesMidifile;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  FMX.ListBox, FMX.TabControl,
  { MidiEditor }
  fLeesMidifileModel,
  cmpTonenObject;


type
  TfrmLeesMidifile = class(TForm)
    bOk: TButton;
    bCancel: TButton;
    lbKanalen: TListBox;
    lbTracks: TListBox;
    lDivision: TLabel;
    lEvents: TLabel;
    lFormaat: TLabel;
    lKanalen: TLabel;
    lOverigeEvents: TLabel;
    lTeksten: TLabel;
    lTracks: TLabel;
    mNootEvents: TMemo;
    mOverigeEvents: TMemo;
    mTeksten: TMemo;
    tcMain: TTabControl;
    pOnder: TPanel;
    tbAlgemeen: TTabItem;
    tbOverige: TTabItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbKanalenChange(Sender: TObject);
    procedure lbTracksChange(Sender: TObject);
  private
    FLeesMidifileModel: TLeesMidifileModel;
    procedure VulTrackControl;
    procedure VulKanalenControl;
    procedure VulTekstenControl;
    procedure VulMidiEventsControl;
  public
    procedure Lees(aFileName: String);
    procedure VulTonenObject(aTonenObject: TTonenObject);
  end;

implementation

{$R *.fmx}

procedure TfrmLeesMidifile.lbKanalenChange(Sender: TObject);
begin
  VulMidiEventsControl;
end;

procedure TfrmLeesMidifile.FormCreate(Sender: TObject);
begin
  FLeesMidifileModel := TLeesMidifileModel.Create;
end;

procedure TfrmLeesMidifile.FormDestroy(Sender: TObject);
begin
  FLeesMidifileModel.Free;
end;

procedure TfrmLeesMidifile.lbTracksChange(Sender: TObject);
begin
  VulKanalenControl;
  VulTekstenControl;
end;

procedure TfrmLeesMidifile.Lees(aFileName: String);
begin
  FLeesMidifileModel.Lees(aFileName);
  VulTrackControl;
  lFormaat.Text := Format('Formaat: %d', [FLeesMidifileModel.MidiObject.Formaat]);
  lDivision.Text := Format('Division: %d', [FLeesMidifileModel.MidiObject.Division]);
end;

procedure TfrmLeesMidifile.VulKanalenControl;
var
  myKanaalIndex: Integer;
begin
  myKanaalIndex := lbKanalen.ItemIndex;
  FLeesMidifileModel.VulKanalen(lbKanalen.Items, lbTracks.ItemIndex);
  lbKanalen.ItemIndex := myKanaalIndex;
  VulMidiEventsControl;
end;

procedure TfrmLeesMidifile.VulTekstenControl;
begin
  FLeesMidifileModel.VulTekstenControl(mTeksten.Lines, lbTracks.ItemIndex);
end;

procedure TfrmLeesMidifile.VulTrackControl;
begin
  FLeesMidifileModel.VulTrackControl(lbTracks.Items);
  VulKanalenControl;
  VulTekstenControl
end;

procedure TfrmLeesMidifile.VulMidiEventsControl;
begin
  FLeesMidifileModel.LeesMidiEvents(mNootEvents.Lines, mOverigeEvents.Lines, lbTracks.ItemIndex, lbKanalen.ItemIndex+1);
end;

procedure TfrmLeesMidifile.VulTonenObject(aTonenObject: TTonenObject);
begin
  FLeesMidifileModel.VulTonenObject(aTonenObject);
end;

end.
