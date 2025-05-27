unit frMidiEditor;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation,
  FMX.Edit,
  System.Generics.Collections,
  FMX.TabControl, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.ListBox, System.Rtti, FMX.Grid.Style, FMX.Grid, FMX.Menus,

  { MidiEditor }
  uTypes,
  cmpObjectInfo,
  fToonEditorModel,
  frStemControls,
  frObjectinfo,
  fMainModel;

type

  { TframeMidiEditor }

  TframeMidiEditor = class(TFrame)
    cbStem: TComboBox;
    eDivision: TEdit;
    miGeselecteerdeMoment: TMenuItem;
    pEventInfos: TPanel;
    frameToonInfo: TframeObjectInfo;
    gbTempoWisselingen: TGroupBox;
    lTrack: TLabel;
    pcMain: TTabControl;
    pbLiniaal: TPaintBox;
    pbEvents: TPaintBox;
    pbTonen: TPaintBox;
    pOnder: TPanel;
    pmLiniaal: TPopupMenu;
    pPaintbox: TPanel;
    pTonen: TPanel;
    pTracks: TPanel;
    sbHorizontaal: TScrollBar;
    sbVerticaal: TScrollBar;
    shAfspeelwijzer: TLine;
    tsEditor: TTabItem;
    tsInfo: TTabItem;
    sgTonen: TStringGrid;
    sgEvents: TStringGrid;
    sgTempoWisselingen: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    StringColumn5: TStringColumn;
    StringColumn6: TStringColumn;
    StringColumn7: TStringColumn;
    StringColumn8: TStringColumn;
    StringColumn9: TStringColumn;
    StringColumn10: TStringColumn;
    StringColumn11: TStringColumn;
    Splitter1: TSplitter;
    procedure cbStemChange(Sender: TObject);
    procedure miGeselecteerdeMomentClick(Sender: TObject);
    procedure pbEventsPaint(Sender: TObject; Canvas: TCanvas);
    procedure pbLiniaalPaint(Sender: TObject; Canvas: TCanvas);
    procedure pbTonenPaint(Sender: TObject; Canvas: TCanvas);
    procedure pbTonenMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure pbTonenMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure pbTonenMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure sbHorizontaalChange(Sender: TObject);
    procedure sbVerticaalChange(Sender: TObject);
    procedure sbHorizontaalMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure sbVerticaalMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure pPaintboxKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure pbEventsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    FModel: TfrmToonEditorModel;
    FStemControls: TObjectList<TframeStemControls>; // om ze makkelijk te kunnen verwijderen
    FEventInfos: TObjectList<TframeObjectInfo>;
    procedure HandleInvalidate(aSender: TObject);
    procedure HandleInvalidateRect(aRect: TRect);
    procedure HandleChangeCursor(aCursor: TMyCursor);
    procedure HandleTekenToonShape(const aParams: TTekenShapeParams);
    procedure HandleTekenEventShape(const aParams: TTekenShapeParams);
    procedure HandleTekenBaan(const aParams: TTekenBaanParams);
    procedure HandleTekenLiniaal(const aParams: TTekenLiniaalParams);
    procedure HandleAfspelerStatusUpdate(const aParams: TAfspelerStatusParams);
    procedure HandleMelding(const aMelding: String);
    procedure HandleEventsGeselecteerd(aObjectInfos: TObjectList<TObjectInfo>);
    procedure HandleLiniaalInvalidated(aSender: TObject);
    procedure ZichtbareStemChange(aSender: TObject);
    procedure VulTempoWisselingen;
    procedure VulToonTekstLijst(aTrackIndex: Integer);
    procedure VulEventsTekstLijst(aTrackIndex: Integer);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Init(aFileName: String; aMainModel: TfrmMainModel);
    procedure Done;
    procedure LeesTonen;
    procedure HandleKeyDown(aKey: Word; aShift: TShiftState);
    procedure VulInfoTab;
    property Model: TfrmToonEditorModel read FModel;
  end;

implementation
uses
  Math,

  cmpStrings2D,
  uMidiConstants,
  fGeselecteerdeMoment;

{$R *.fmx}

procedure InvalidateControl(aControl: TControl);
var
  R: TRectF;
begin
    R.Left := 0;
    R.Top := 0;
    R.Right := aControl.Width;
    R.Bottom := aControl.Height;
    aControl.InvalidateRect(R);
end;

const
  nmFrameStemControls = 'frameStemControls';

  function GetFillColor(aKleur: TKleur): TAlphaColor;
  begin
    case aKleur of
      klRood: Result := TAlphaColorRec.Red;
      klBlauw: Result := TAlphaColorRec.Blue;
      klGroen: Result := TAlphaColorRec.Green;
      klZwart: Result := TAlphaColorRec.Black;
      klLichtBlauw: Result := TAlphaColorRec.Aqua;
      else
        Result := TAlphaColorRec.Black;
    end;
  end;

constructor TframeMidiEditor.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FModel := TfrmToonEditorModel.Create;
  FModel.OnInvalidateRect := HandleInvalidateRect;
  FModel.OnChangeCursor:= HandleChangeCursor;
  FModel.OnTekenToonShape := HandleTekenToonShape;
  FModel.OnTekenEventShape := HandleTekenEventShape;
  FModel.OnTekenBaan := HandleTekenBaan;
  FModel.OnTekenLiniaal := HandleTekenLiniaal;
  FModel.OnInvalidate := HandleInvalidate;
  FModel.OnAfspelerStatus := HandleAfspelerStatusUpdate;
  FModel.OnMelding := HandleMelding;
  FStemControls := TObjectList<TframeStemControls>.Create;
  FEventInfos := TObjectList<TframeObjectInfo>.Create;
  sbVerticaal.Min := midiLaagsteToon;
  sbVerticaal.Max := midiHoogsteToon;
  sbVerticaal.Value := midiLaagsteToon + (midiHoogsteToon - midiLaagsteToon) div 2;
end;

destructor TframeMidiEditor.Destroy;
begin
  FModel.Free;
  FStemControls.Free;
  FEventInfos.Free;
  inherited Destroy;
end;

procedure TframeMidiEditor.sbVerticaalChange(Sender: TObject);
begin
  FModel.ScrollVerticaal(Trunc(sbVerticaal.Value));
end;

procedure TframeMidiEditor.sbVerticaalMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  FModel.ZoomVerticaal(WheelDelta > 0);
end;

procedure TframeMidiEditor.Init(aFileName: String; aMainModel: TfrmMainModel);
begin
  FModel.Init(aFileName, aMainModel);
  frameToonInfo.Init(FModel);
  FModel.OnEventsGeselecteerd := HandleEventsGeselecteerd;
  FModel.OnLiniaalInvalidated := HandleLiniaalInvalidated;
  pcMain.ActiveTab := tsEditor;
end;

procedure TframeMidiEditor.Done;
begin
  FModel.Done;
  frameToonInfo.Done;
end;

procedure TframeMidiEditor.LeesTonen;
var
  I: Integer;
  myFrame: TframeStemControls;
  Y: Integer;
begin
  FModel.LeesTonenObject;
  Y := 0;
  FStemControls.Clear;
  for I := 0 to FModel.AantalTracks-1 do
  begin
    myFrame := TframeStemControls.Create(Self);
    myFrame.Name := nmFrameStemControls+ IntToStr(I);
    myFrame.Position.Y := Y;
    Inc(Y, Round(myFrame.Height));
    myFrame.Parent := pTracks;
    myFrame.lNaam.Text := FModel.TrackNaam[I];
    myFrame.lNaam.TextSettings.FontColor := GetFillColor(FModel.Instellingen.GetTrackKleur(I));
    myFrame.cbZichtbaar.IsChecked := True;
    myFrame.cbZichtbaar.OnChange := ZichtbareStemChange;
    FStemControls.Add(myFrame);
  end;
  sbHorizontaal.Max := FModel.MaxMoment;
  sbHorizontaal.SmallChange := FModel.MaxMoment div 100; // 1 procent
end;

procedure TframeMidiEditor.pbTonenMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FModel.ToonShapesMouseDown(Round(X), Round(Y));
end;

procedure TframeMidiEditor.pbTonenMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
  FModel.MouseMove(Round(X), Round(Y));
end;

procedure TframeMidiEditor.pbTonenMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FModel.MouseUp;
end;

procedure TframeMidiEditor.pbTonenPaint(Sender: TObject; Canvas: TCanvas);
var
  myRectF: TRectF;
  myRect: TRect;
  I: Integer;
begin
  myRectF := RectF(0, 0, 0, 0);
  for i := 0 to pbTonen.Scene.GetUpdateRectsCount-1 do
    UnionRectF(myRectF, myRectF, pbTonen.Scene.GetUpdateRect(i));
  with myRectF do
    myRect := Rect(Trunc(Left), Trunc(Top), Trunc(Right), Trunc(Bottom));
  FModel.TekenToonShapes(myRect);
end;

procedure TframeMidiEditor.cbStemChange(Sender: TObject);
begin
  if cbStem.ItemIndex >= 0 then
  begin
    VulToonTekstLijst(cbStem.ItemIndex);
    VulEventsTekstLijst(cbStem.ItemIndex);
  end;
end;

procedure TframeMidiEditor.miGeselecteerdeMomentClick(Sender: TObject);
var
  F: TfrmGeselecteerdeMoment;
begin
  F := TfrmGeselecteerdeMoment.Create(Self);
  try
    F.Init(FModel.AangewezenMoment);
    if F.ShowModal = mrOK then
    begin
      FModel.VerplaatsAangewezenMoment(StrToInt(F.eNaarMoment.Text));
      cbStemChange(nil);
    end;
  finally
    F.Free;
  end;
end;

procedure TframeMidiEditor.pbEventsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FModel.EventShapesMouseDown(Round(X), Round(Y));
end;

procedure TframeMidiEditor.pbEventsPaint(Sender: TObject; Canvas: TCanvas);
var
  myRectF: TRectF;
  myRect: TRect;
  I: Integer;
begin
  myRectF := RectF(0, 0, 0, 0);
  for i := 0 to pbEvents.Scene.GetUpdateRectsCount-1 do
    UnionRectF(myRectF, myRectF, pbEvents.Scene.GetUpdateRect(i));
  with myRectF do
    myRect := Rect(Trunc(Left), Trunc(Top), Trunc(Right), Trunc(Bottom));
  FModel.TekenTrackEvents(myRect);
end;

procedure TframeMidiEditor.pbLiniaalPaint(Sender: TObject; Canvas: TCanvas);
var
  myRectF: TRectF;
  myRect: TRect;
  I: Integer;
begin
  myRectF := RectF(0, 0, 0, 0);
  for i := 0 to pbTonen.Scene.GetUpdateRectsCount-1 do
    UnionRectF(myRectF, myRectF, pbTonen.Scene.GetUpdateRect(i));
  with myRectF do
    myRect := Rect(Trunc(Left), Trunc(Top), Trunc(Right), Trunc(Bottom));
  FModel.TekenLiniaal(myRect);
end;

procedure TframeMidiEditor.HandleTekenBaan(const aParams: TTekenBaanParams);
var
  myRect: TRectF;
  myCanvas: TCanvas;
begin
  myCanvas := pbTonen.Canvas;
    { achtergrond }
  myCanvas.Stroke.Kind := TBrushKind.None;
  myCanvas.Fill.Kind := TBrushKind.Solid;
  if Odd(aParams.ToonHoogte) then
    myCanvas.Fill.Color := TAlphaColorRec.Alpha or TAlphaColor($E0FFFF)
  else
    myCanvas.Fill.Color := TAlphaColorRec.White;
  myRect.Top := aParams.Top;
  myRect.Bottom := aParams.Bottom;
  myRect.Left := 0;
  myRect.Right := pbTonen.Width;
  myCanvas.FillRect(myRect, 0, 0, AllCorners, 1, TCornerType.Round);
end;

procedure TframeMidiEditor.pPaintboxKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkDown then
    FModel.VerplaatsVerticaal(-1)
  else if Key = vkUp then
    FModel.VerplaatsVerticaal(1)
end;

procedure TframeMidiEditor.HandleTekenToonShape(const aParams: TTekenShapeParams);
var
  myCanvas: TCanvas;
  myRect: TRect;
  myKleur: TKleur;
begin
  myKleur := FModel.Instellingen.GetTrackKleur(aParams.TrackIndex);
  myCanvas := pbTonen.Canvas;
  myCanvas.Fill.Color := GetFillColor(myKleur);
  if aParams.GeselecteerdeShape then
    myCanvas.Fill.Kind := TBrushKind.Solid
  else
    myCanvas.Fill.Kind := TBrushKind.None;
  myCanvas.Stroke.Color := myCanvas.Fill.Color;
  myCanvas.Stroke.Kind := TBrushKind.Solid;
  myCanvas.Stroke.Thickness := 1;
  myRect := aParams.Rect;
  myRect := aParams.Rect;
  InflateRect(myRect, -1, -1);
  myCanvas.FillRect(myRect, 0, 0, AllCorners, 1, TCornerType.Round);
  myCanvas.DrawRect(myRect, 0, 0, AllCorners, 1, TCornerType.Round);
end;

procedure TframeMidiEditor.HandleTekenEventShape(const aParams: TTekenShapeParams);
var
  myCanvas: TCanvas;
  R: TRect;
  myKleur: TKleur;
begin
  myKleur := FModel.Instellingen.GetTrackKleur(aParams.TrackIndex);
  myCanvas := pbEvents.Canvas;
  myCanvas.Stroke.Thickness := 1;
  myCanvas.Stroke.Kind := TBrushKind.Solid;
  myCanvas.Fill.Kind := TBrushKind.Solid;
  myCanvas.Fill.Color := GetFillColor(myKleur);
  myCanvas.Stroke.Color := myCanvas.Fill.Color;
  R := aParams.Rect;
  InflateRect(R, -1, -1);
  myCanvas.FillRect(R, 0, 0, AllCorners, 1, TCornerType.Round);
end;

procedure TframeMidiEditor.HandleTekenLiniaal(const aParams: TTekenLiniaalParams);
var
  myCanvas: TCanvas;
  R: TRect;
  myMoment: Integer;
  P1, P2: TPointF;
begin
  myCanvas := pbLiniaal.Canvas;
  if aParams.Init then
  begin
    myCanvas.Fill.Kind := TBrushKind.Solid;
    myCanvas.Fill.Color := TAlphaColorRec.Lightgray;
    R := TRect.Create(0, 0, Round(pbLiniaal.Width), 26);
    myCanvas.FillRect(R, 0, 0, AllCorners, 1, TCornerType.Round);
  end
  else if aParams.TekenAangewezenMoment then
  begin
    myCanvas.Stroke.Kind := TBrushKind.Solid;
    myCanvas.Stroke.Color := TAlphaColorRec.Red;
    P1.X := aParams.X;
    P1.Y := 0;
    P2.X := aParams.X;
    P2.Y := 26;
    myCanvas.DrawLine(P1, P2, 1);
  end
  else
  begin
    myCanvas.Stroke.Kind := TBrushKind.Solid;
    myCanvas.Stroke.Color := TAlphaColorRec.Black;
    myCanvas.Stroke.Thickness := 1;
    P1.X := aParams.X;
    P1.Y := 0;
    P2.X := aParams.X;
    P2.Y := 10;
    myCanvas.DrawLine(P1, P2, 1);
    myCanvas.Font.Size := 8;
    myCanvas.Fill.Color := TAlphaColorRec.Black;
    myCanvas.Fill.Kind := TBrushKind.Solid;
    R := Rect(aParams.X-8, 10, aParams.X+8, 20);
    myMoment := aParams.Moment div aParams.Division;
    if (myMoment mod 4 = 0)
    and (myMoment <> 0) then
      myCanvas.FillText(R, IntToStr(myMoment), False, 1, [], TTextAlign.Center, TTextAlign.Leading);
  end;
end;

procedure TframeMidiEditor.handleAfspelerStatusUpdate(const aParams: TAfspelerStatusParams);
begin
  if aParams.Gestart then
  begin
    shAfspeelwijzer.Visible := True;
    shAfspeelwijzer.Position.X := aParams.X;
  end
  else
    shAfspeelwijzer.Visible := False;
end;

procedure TframeMidiEditor.sbHorizontaalChange(Sender: TObject);
begin
  FModel.ScrollHorizontaal(Trunc(sbHorizontaal.Value));
end;

procedure TframeMidiEditor.HandleInvalidateRect(aRect: TRect);
begin
  InvalidateControl(pbTonen);
  InvalidateControl(pbLiniaal);
  InvalidateControl(pbEvents);
end;

procedure TframeMidiEditor.HandleInvalidate(aSender: TObject);
begin
  InvalidateControl(pbTonen);
  InvalidateControl(pbLiniaal);
  InvalidateControl(pbEvents);
end;

procedure TframeMidiEditor.sbHorizontaalMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  FModel.ZoomHorizontaal(WheelDelta > 0);
end;

procedure TframeMidiEditor.HandleChangeCursor(aCursor: TMyCursor);
begin
  with pbTonen do
    case aCursor of
      mycrDefault: Cursor := crDefault;
      mycrSizeWE:  Cursor := crSizeWE;
      mycrSizeAll: Cursor := crSizeAll;
    else
      Cursor := crDefault;
    end;
end;

procedure TframeMidiEditor.ZichtbareStemChange(aSender: TObject);
var
  myCheckBox: TCheckBox;
  S: String;
  myTrackIndex: Integer;
begin
  myCheckBox := aSender as TCheckBox;
  S := myCheckBox.Parent.Name;
  Delete(S, 1, Length(nmFrameStemControls));
  myTrackIndex := StrToInt(S);
  FModel.TrackZichtbaar[myTrackIndex] := myCheckBox.IsChecked;
  InvalidateControl(pbTonen);
  InvalidateControl(pbEvents);
end;

procedure TframeMidiEditor.HandleKeyDown(aKey: Word; aShift: TShiftState);
begin
  if aKey = vkDown then
    FModel.VerplaatsVerticaal(-1)
  else if aKey = vkUp then
    FModel.VerplaatsVerticaal(1)
end;

procedure TframeMidiEditor.VulInfoTab;
begin
  LeesTonen;
  FModel.VulStemLijst(cbStem.Items);
  if cbStem.Items.Count > 0 then
    cbStem.ItemIndex := 0;
  cbStemChange(nil);
  VulTempoWisselingen;
  eDivision.Text := IntToStr(FModel.TonenObject.Division);
end;


procedure VulStringGrid(aStringGrid: TStringGrid; aStrings: TStrings2D);
var
  myRij,
  myKolom: Integer;
const
  FixedRows = 1; { ik weet niet wat hetequivalent is in fm voor TStringGrid.FixedRows }
begin
  aStringGrid.RowCount := Max(aStrings.AantalRijen+FixedRows, 2);
  if aStrings.AantalRijen = 0 then
    aStringGrid.Visible := False
  else
  begin
    aStringGrid.Visible := True;
    for myRij := 0 to aStrings.AantalRijen-1 do
    begin
      for myKolom := 0 to aStrings.AantalKolommen-1 do
        aStringGrid.Cells[myKolom, myRij+FixedRows] := aStrings[myKolom, myRij];
    end;
    if FixedRows >= 1 then
      for myKolom := 0 to aStrings.AantalKolommen-1 do
        aStringGrid.Cells[myKolom, 0] := aStrings.Header[myKolom];
  end;
end;

procedure TframeMidiEditor.VulTempoWisselingen;
var
  myStrings: TStrings2D;
begin
  myStrings := TStrings2D.Create;
  try
    FModel.VulTempoWisselingen(myStrings);
    VulStringGrid(sgTempoWisselingen, myStrings);
  finally
    myStrings.Free;
  end;
end;

procedure TframeMidiEditor.VulToonTekstLijst(aTrackIndex: Integer);
var
  myStrings: TStrings2D;
begin
  myStrings := TStrings2D.Create;
  try
    FModel.VulToonTekstLijst(myStrings, aTrackIndex);
    VulStringGrid(sgTonen, myStrings);
  finally
    myStrings.Free;
  end;
end;

procedure TframeMidiEditor.VulEventsTekstLijst(aTrackIndex: Integer);
var
  myStrings: TStrings2D;
begin
  myStrings := TStrings2D.Create;
  try
    FModel.VulEventTekstLijst(myStrings, aTrackIndex);
    VulStringGrid(sgEvents, myStrings);
  finally
    myStrings.Free;
  end;
end;

procedure TframeMidiEditor.HandleMelding(const aMelding: String);
begin
  ShowMessage(aMelding);
end;

procedure TframeMidiEditor.HandleEventsGeselecteerd(aObjectInfos: TObjectList<TObjectInfo>);
var
  myObjectInfo: TObjectInfo;
  myObjectInfoFrame: TframeObjectInfo;
begin
  FEventInfos.Clear;
  for myObjectInfo in aObjectInfos do
  begin
    myObjectInfoFrame := TframeObjectInfo.Create(Self);
    FEventInfos.Add(myObjectInfoFrame);
    myObjectInfoFrame.Name := '';
    myObjectInfoFrame.Align := TAlignLayout.Left;
    myObjectInfoFrame.Parent := pEventInfos;
    myObjectInfoFrame.Read(myObjectInfo);
  end;
end;

procedure TframeMidiEditor.HandleLiniaalInvalidated(aSender: TObject);
begin
  with pbLiniaal do
    InvalidateRect(TRectF.Create(0, 0, Width, Height));
end;

end.
