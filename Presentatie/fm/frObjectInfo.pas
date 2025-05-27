unit frObjectInfo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Grid,

  cmpObjectInfo,
  fToonEditorModel;


type
  TframeObjectInfo = class(TFrame)
    sgItems: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    lNaam: TLabel;
  private
    FModel: TfrmToonEditorModel;
    procedure handleToonGeselecteerd(const aObjectInfo: TObjectInfo);
  public
    procedure Init(aModel: TfrmToonEditorModel);
    procedure Read(aObjectInfo: TObjectInfo);
    procedure Done;
  end;

implementation

{$R *.fmx}

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
    lNaam.Text := aObjectInfo.Naam;
    for I := 0 to aObjectInfo.ItemCount-1 do
    begin
      sgItems.Cells[0, I] := aObjectInfo.GetItem(I).Naam;
      sgItems.Cells[1, I] := aObjectInfo.GetItem(I).Waarde;
    end;
  end;
end;

end.
