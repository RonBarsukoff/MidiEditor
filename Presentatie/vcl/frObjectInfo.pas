unit frObjectInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.StdCtrls,

  cmpObjectInfo,
  fToonEditorModel;

type

  { TframeObjectInfo }

  TframeObjectInfo = class(TFrame)
    lNaam: TLabel;
    sgItems: TStringGrid;
  private
    FModel: TfrmToonEditorModel;
    procedure handleToonGeselecteerd(const aObjectInfo: TObjectInfo);
  public
    procedure Init(aModel: TfrmToonEditorModel);
    procedure Read(aObjectInfo: TObjectInfo);
    procedure Done;
  end;

implementation

{$R *.dfm}

procedure TframeObjectInfo.Init(aModel: TfrmToonEditorModel);
begin
  FModel := aModel;
  FModel.OnToonGeselecteerd := handleToonGeselecteerd;
end;

procedure TframeObjectInfo.Done;
begin
  FModel.OnToonGeselecteerd := nil;
end;

procedure TframeObjectInfo.handleToonGeselecteerd(const aObjectInfo: TObjectInfo);
begin
  Read(aObjectInfo);
end;

procedure TframeObjectInfo.Read(aObjectInfo: TObjectInfo);
var
  I: Integer;
begin
  if Assigned(aObjectInfo) then
  begin
    sgItems.RowCount := aObjectInfo.ItemCount;
    lNaam.Caption := aObjectInfo.Naam;
    for I := 0 to aObjectInfo.ItemCount-1 do
    begin
      sgItems.Cells[0, I] := aObjectInfo.GetItem(I).Naam;
      sgItems.Cells[1, I] := aObjectInfo.GetItem(I).Waarde;
    end;
  end;
end;

end.
