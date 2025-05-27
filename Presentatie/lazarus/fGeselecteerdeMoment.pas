unit fGeselecteerdeMoment;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,

  uTypes;

type

  { TfrmGeselecteerdeMoment }

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

{$R *.lfm}

procedure TfrmGeselecteerdeMoment.Init(aMoment: TMoment);
begin
  eMoment.Text := IntToStr(aMoment);
  eNaarMoment.Text := IntToStr(aMoment);
end;

end.
