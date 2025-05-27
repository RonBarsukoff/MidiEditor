unit frObjectInfo;
{$ifdef fpc}
{$mode DelphiUnicode}
{$endif}

interface

uses
  Classes, SysUtils, Forms, Controls, Grids, StdCtrls,

  cmpObjectInfo,
  fToonEditorModel;

type

  { TframeObjectInfo }

  TframeObjectInfo = class(TFrame)
    lNaam: TLabel;
    sgItems: TStringGrid;
    procedure sgItemsGetCellHint(Sender: TObject; ACol, ARow: Integer;
      var HintText: String);
  private
    FModel: TfrmToonEditorModel;
    procedure handleToonGeselecteerd(const aObjectInfo: TObjectInfo);
  public
    procedure Init(aModel: TfrmToonEditorModel);
    procedure Read(aObjectInfo: TObjectInfo);
    procedure Done;
  end;

implementation

{$R *.lfm}

procedure TframeObjectInfo.Init(aModel: TfrmToonEditorModel);
begin
  FModel := aModel;
  FModel.OnToonGeselecteerd := handleToonGeselecteerd;
end;

procedure TframeObjectInfo.Done;
begin
  FModel.OnToonGeselecteerd := nil;
end;

procedure TframeObjectInfo.sgItemsGetCellHint(Sender: TObject; ACol,
  ARow: Integer; var HintText: String);
begin
  HintText := sgItems.Cells[aCol, aRow];
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
