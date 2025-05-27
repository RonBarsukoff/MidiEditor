unit fGeselecteerdeMoment;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,

  uTypes;

type
  TfrmGeselecteerdeMoment = class(TForm)
    bOk: TButton;
    bCancel: TButton;
    eMoment: TLabeledEdit;
    eNaarMoment: TLabeledEdit;
  private
  public
    procedure Init(aMoment: TMoment);
  end;

var
  frmGeselecteerdeMoment: TfrmGeselecteerdeMoment;

implementation

{$R *.dfm}

procedure TfrmGeselecteerdeMoment.Init(aMoment: TMoment);
begin
  eMoment.Text := IntToStr(aMoment);
  eNaarMoment.Text := IntToStr(aMoment);
end;

end.
