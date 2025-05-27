unit fGeselecteerdeMoment;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation,

  uTypes;

type
  TfrmGeselecteerdeMoment = class(TForm)
    bOk: TButton;
    bCancel: TButton;
    eMoment: TEdit;
    eNaarMoment: TEdit;
    lMoment: TLabel;
    lNaarMoment: TLabel;
  private
  public
    procedure Init(aMoment: TMoment);
  end;

var
  frmGeselecteerdeMoment: TfrmGeselecteerdeMoment;

implementation

{$R *.fmx}

procedure TfrmGeselecteerdeMoment.Init(aMoment: TMoment);
begin
  eMoment.Text := IntToStr(aMoment);
  eNaarMoment.Text := IntToStr(aMoment);
end;

end.
