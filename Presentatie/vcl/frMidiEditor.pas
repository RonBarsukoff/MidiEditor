unit frMidiEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  System.Generics.Collections, Vcl.ComCtrls, Vcl.Mask, Vcl.Grids, Vcl.Menus,

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
    eDivision: TLabeledEdit;
    miGeselecteerdeMoment: TMenuItem;
    pEventInfos: TFlowPanel;
    frameToonInfo: TframeObjectInfo;
    gbTempoWisselingen: TGroupBox;
    lTrack: TLabel;
    PageControl1: TPageControl;
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
    shAfspeelwijzer: TShape;
    sgTempoWisselingen: TStringGrid;
    sgTonen: TStringGrid;
    sgEvents: TStringGrid;
    Splitter1: TSplitter;
    tsEditor: TTabSheet;
    tsInfo: TTabSheet;
    procedure cbStemChange(Sender: TObject);
    procedure miGeselecteerdeMomentClick(Sender: TObject);
    procedure pbEventsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbEventsPaint(Sender: TObject);
    procedure pbLiniaalPaint(Sender: TObject);
    procedure pbTonenPaint(Sender: TObject);
    procedure pbTonenMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pbTonenMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbTonenMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sbHorizontaalChange(Sender: TObject);
    procedure sbVerticaalChange(Sender: TObject);
    procedure FrameMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
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
  System.UITypes,
  Math,

  cmpStrings2D,
  uMidiConstants,
  fGeselecteerdeMoment;

{$R *.dfm}

const
  nmFrameStemControls = 'frameStemControls';

  function GetFillColor(aKleur: TKleur): TColor;
  begin
    case aKleur of
      klRood: Result := clRed;
      klBlauw: Result := clBlue;
      klGroen: Result := clGreen;
      klZwart: Result := clBlack;
      klLichtBlauw: Result := clAqua;
      else
        Result := clBlack;
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
  sbVerticaal.Position := midiLaagsteToon + (midiHoogsteToon - midiLaagsteToon) div 2;
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
  FModel.ScrollVerticaal(sbVerticaal.Position);
end;

procedure TframeMidiEditor.Init(aFileName: String; aMainModel: TfrmMainModel);
begin
  FModel.Init(aFileName, aMainModel);
  frameToonInfo.Init(FModel);
  FModel.OnEventsGeselecteerd := HandleEventsGeselecteerd;
  FModel.OnLiniaalInvalidated := HandleLiniaalInvalidated;
  PageControl1.ActivePage := tsEditor;
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
begin
  FModel.LeesTonenObject;

  FStemControls.Clear;
  for I := FModel.AantalTracks-1 downto 0 do
  begin
    myFrame := TframeStemControls.Create(Self);
    myFrame.Name := nmFrameStemControls+ IntToStr(I);
    myFrame.Align := alTop;
    myFrame.Parent := pTracks;
    myFrame.lNaam.Caption := FModel.TrackNaam[I];
    myFrame.lNaam.Font.Color := GetFillColor(FModel.Instellingen.GetTrackKleur(I));
    myFrame.cbZichtbaar.Checked := True;
    myFrame.cbZichtbaar.OnClick := ZichtbareStemChange;
    FStemControls.Add(myFrame);
  end;
  sbHorizontaal.Max := FModel.MaxMoment;
  sbHorizontaal.SmallChange := Max(1, FModel.MaxMoment div 100); // 1 procent
  sbHorizontaal.LargeChange := Max(1, FModel.MaxMoment div 10); // 10 procent
end;

procedure TframeMidiEditor.pbTonenMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FModel.ToonShapesMouseDown(X, Y);
end;

procedure TframeMidiEditor.pbTonenMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  FModel.MouseMove(X, Y);
end;

procedure TframeMidiEditor.pbTonenMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FModel.MouseUp;
end;

procedure TframeMidiEditor.pbTonenPaint(Sender: TObject);
var
  myRect: TRect;
begin
  myRect := pbTonen.Canvas.ClipRect;
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
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FModel.EventShapesMouseDown(X, Y);
end;

procedure TframeMidiEditor.pbEventsPaint(Sender: TObject);
var
  myRect: TRect;
begin
  pbEvents.Canvas.Brush.Color := clInfoBk;
  with pbEvents do
    Canvas.FillRect(Rect(0, 0, Width, Height));
  myRect := pbEvents.Canvas.ClipRect;
  FModel.TekenTrackEvents(myRect);
end;

procedure TframeMidiEditor.pbLiniaalPaint(Sender: TObject);
var
  myRect: TRect;
begin
  myRect := pbLiniaal.Canvas.ClipRect;
  FModel.TekenLiniaal(myRect);
end;

procedure TframeMidiEditor.HandleTekenBaan(const aParams: TTekenBaanParams);
var
  myRect: TRect;
  myCanvas: TCanvas;
begin
  myCanvas := pbTonen.Canvas;
  myCanvas.Pen.Style := TPenStyle.psSolid;
  myCanvas.Pen.Width := 0;
  myCanvas.Brush.Style := TBrushStyle.bsSolid;
  if Odd(aParams.ToonHoogte) then
  begin
    myCanvas.Brush.Color := TColor($FFFFE0); //clAqua
    myCanvas.Pen.Color := TColor($FFFFD0); //myCanvas.Brush.Color;
  end
  else
  begin
    myCanvas.Brush.Color := clWhite;
    myCanvas.Pen.Color:= clWhite;
  end;
  myRect.Top := aParams.Top;
  myRect.Bottom := aParams.Bottom;
  myRect.Left := 0;
  myRect.Right := pbTonen.Width;
  myCanvas.Rectangle(myRect);
end;

procedure TframeMidiEditor.HandleTekenToonShape(const aParams: TTekenShapeParams);
var
  myCanvas: TCanvas;
  myKleur: TKleur;
  myRect: TRect;
begin
  myKleur := FModel.Instellingen.GetTrackKleur(aParams.TrackIndex);
  myCanvas := pbTonen.Canvas;
  with myCanvas do
  begin
    Brush.Color := GetFillColor(myKleur);
    if aParams.GeselecteerdeShape then
      Brush.Style := bsSolid
    else
      Brush.Style := bsFDiagonal;
    Pen.Color := Brush.Color;
    Pen.Style := psSolid;
    Pen.Width := 1;
    myRect := aParams.Rect;
    myRect.Left := myRect.Left + 1;
    myRect.Right := myRect.Right;
    Rectangle(myRect);
  end;
end;

procedure TframeMidiEditor.HandleTekenEventShape(const aParams: TTekenShapeParams);
var
  myCanvas: TCanvas;
  myKleur: TKleur;
begin
  myKleur := FModel.Instellingen.GetTrackKleur(aParams.TrackIndex);
  myCanvas := pbEvents.Canvas;
  with myCanvas do
  begin
    Brush.Color := GetFillColor(myKleur);
    Brush.Style := bsSolid;
    FillRect(aParams.Rect);
  end;
end;

procedure TframeMidiEditor.HandleTekenLiniaal(const aParams: TTekenLiniaalParams);
var
  myCanvas: TCanvas;
  R: TRect;
  myMoment: Integer;
begin
  myCanvas := pbLiniaal.Canvas;
  if aParams.Init then
  begin
    myCanvas.Brush.Style := bsSolid;
    myCanvas.Brush.Color := clLtGray;
    R := Rect(0, 0, pbLiniaal.Width, 26);
    myCanvas.FillRect(R);
  end
  else if aParams.TekenAangewezenMoment then
  begin
    myCanvas.Pen.Style := psSolid;
    myCanvas.Pen.Color := clRed;
    myCanvas.MoveTo(aParams.X, 0);
    myCanvas.LineTo(aParams.X, 26);
  end
  else
  begin
    myCanvas.Pen.Style := TPenStyle.psSolid;
    myCanvas.Pen.Width := 0;
    myCanvas.Pen.Color := clBlack;
    myCanvas.MoveTo(aParams.X, 0);
    myCanvas.LineTo(aParams.X, 10);
    myCanvas.Font.Size := 6;
    myCanvas.Brush.Style := bsClear;
    R := Rect(aParams.X-8, 10, aParams.X+8, 20);
    myMoment := aParams.Moment div aParams.Division;
    if (myMoment mod 4 = 0)
    and (myMoment <> 0) then
    begin
      SetTextAlign(myCanvas.Handle, ta_Top or ta_Center);
      myCanvas.TextRect(R, aParams.X, 10, IntToStr(myMoment));
    end;
  end;
end;

procedure TframeMidiEditor.HandleAfspelerStatusUpdate(const aParams: TAfspelerStatusParams);
begin
  if aParams.Gestart then
  begin
    shAfspeelwijzer.Visible := True;
    shAfspeelwijzer.Left := aParams.X;
  end
  else
    shAfspeelwijzer.Visible := False;
end;

procedure TframeMidiEditor.sbHorizontaalChange(Sender: TObject);
begin
  FModel.ScrollHorizontaal(sbHorizontaal.Position);
end;

procedure TframeMidiEditor.HandleInvalidateRect(aRect: TRect);
begin
  pbTonen.Invalidate;
  pbLiniaal.Invalidate;
  pbEvents.Invalidate;
end;

procedure TframeMidiEditor.HandleInvalidate(aSender: TObject);
begin
  pbTonen.Invalidate;
  pbLiniaal.Invalidate;
  pbEvents.Invalidate;
end;

procedure TframeMidiEditor.FrameMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  myPoint: TPoint;
begin
  { in vcl is de MousePos relatief tov het scherm  }
  myPoint := sbVerticaal.ScreenToClient(MousePos);
  if (myPoint.X >= 0)
  and (myPoint.Y <= sbVerticaal.Height) then
    FModel.ZoomVerticaal(WheelDelta > 0)
  else
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
  FModel.TrackZichtbaar[myTrackIndex] := myCheckBox.Checked;
  pbTonen.Invalidate;
  pbEvents.Invalidate;
end;

procedure TframeMidiEditor.HandleKeyDown(aKey: Word; aShift: TShiftState);
begin
  if aKey = vk_Down then
    FModel.VerplaatsVerticaal(-1)
  else if aKey = vk_Up then
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
begin
  aStringGrid.RowCount := Max(aStrings.AantalRijen+aStringGrid.FixedRows, 2);
  if aStrings.AantalRijen = 0 then
    aStringGrid.Visible := False
  else
  begin
    aStringGrid.Visible := True;
    for myRij := 0 to aStrings.AantalRijen-1 do
    begin
      for myKolom := 0 to aStrings.AantalKolommen-1 do
        aStringGrid.Cells[myKolom, myRij+aStringGrid.FixedRows] := aStrings[myKolom, myRij];
    end;
    if aStringGrid.FixedRows >= 1 then
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
  sgEvents.ColWidths[2] := 64;
  sgEvents.ColWidths[3] := 120;
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
    myObjectInfoFrame.Align := alLeft;
    myObjectInfoFrame.Parent := pEventInfos;
    myObjectInfoFrame.Read(myObjectInfo);
  end;
end;

procedure TframeMidiEditor.HandleLiniaalInvalidated(aSender: TObject);
begin
  pbLiniaal.Invalidate;
end;

end.
