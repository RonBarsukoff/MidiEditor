unit fLeesMidifile;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,

  { MidiEditor }
  fLeesMidifileModel,
  cmpTonenObject;

type

  { TfrmLeesMidifile }

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
    PageControl1: TPageControl;
    pOnder: TPanel;
    tsAlgemeen: TTabSheet;
    tsOverige: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbKanalenClick(Sender: TObject);
    procedure lbTracksClick(Sender: TObject);
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

{$R *.dfm}

procedure TfrmLeesMidifile.lbKanalenClick(Sender: TObject);
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

procedure TfrmLeesMidifile.lbTracksClick(Sender: TObject);
begin
  VulKanalenControl;
  VulTekstenControl;
end;

procedure TfrmLeesMidifile.Lees(aFileName: String);
begin
  FLeesMidifileModel.Lees(aFileName);
  VulTrackControl;
  lFormaat.Caption := Format('Formaat: %d', [FLeesMidifileModel.MidiObject.Formaat]);
  lDivision.Caption := Format('Division: %d', [FLeesMidifileModel.MidiObject.Division]);
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
