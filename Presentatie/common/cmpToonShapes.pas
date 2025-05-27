unit cmpToonShapes;
{$ifdef fpc}
{$mode DelphiUnicode}
{$endif}

interface
uses
  Classes,
  Generics.Collections,
  {$ifndef fpc}
  Types,
  {$endif}

  { midieditor }
  cmpShapes,
  cmpToon,
  cmpShapeWerkruimte,
  cmpToonAfspeler,
  uTypes,
  cmpTonenObject;

type
  TToonshapes = class;

  TToonShape = class(TObject)
  private
    FOwner: TToonShapes;
  public
    Toon: TToon;
    Rect: TRect;
    constructor Create(aOwner: TToonshapes; aToon: TToon);
    procedure Resize;
    procedure BepaalEigenschappen;
  end;

  TInvalidateRectEvent = procedure(aRect: TRect) of object;
  TChangeCursorEvent = procedure(aCursor: TMyCursor) of object;
  TToonShapesToonGeselecteerdEvent = procedure(const aToon: TToon) of object;

  TToonShapes = class(TShapes)
  private
    FOpgepakteShape: TToonShape;
    FGeselecteerdeShape: TToonShape;
    FBeginVerplaats: TPoint;
    FBeginVerplaatsShapeRect: TRect;
    FToonAfspeler: TToonAfspeler;
    procedure InvalidateRect(aRect: TRect);
    procedure ChangeCursor(aCursor: TMyCursor);
    function BepaalVerplaatsMode(aShape: TToonShape; aX, aY: Integer): TVerplaatsMode;
    function AangewezenShape(aX, aY: Integer): TToonShape;
    procedure SpeelToon(aToon: TToon);
    procedure ToonGeselecteerd(aToon: TToon);
    procedure handleShapeWerkruimteGewijzigd;
  protected
    procedure ResizeShapes; override;
  public
    Shapes: TObjectList<TToonShape>;
    OnInvalidateRect: TInvalidateRectEvent;
    OnChangeCursor: TChangeCursorEvent;
    OnToonGeselecteerd: TToonshapesToonGeselecteerdEvent;
    constructor Create(aShapeWerkruimte: TShapeWerkruimte);
    procedure Init(aToonAfspeler: TToonAfspeler);
    destructor Destroy; override;
    procedure Clear;
    procedure MouseDown(X, Y: Integer);
    procedure MouseUp;
    procedure MouseMove(X, Y: Integer);
    procedure Lees(aToonLijst: TToonLijst);
    function MaxMoment: TMoment;
    procedure VerplaatsVerticaal(aDelta: Integer);
    procedure GetPositiesY(aToonhoogte: Byte; var YTop, YBottom: Integer);

    property GeselecteerdeShape: TToonShape read FGeselecteerdeShape;
  end;

implementation
uses
  uMidiConstants;

constructor TToonShapes.Create(aShapeWerkruimte: TShapeWerkruimte);
begin
  inherited Create(aShapeWerkruimte);
  FShapeWerkruimte.AddListener(handleShapeWerkruimteGewijzigd);
  Shapes := TObjectList<TToonShape>.Create;
end;

destructor TToonShapes.Destroy;
begin
  FShapeWerkruimte.RemoveListener(handleShapeWerkruimteGewijzigd);
  Clear;
  Shapes.Free;
  inherited Destroy;
end;

procedure TToonShapes.Init(aToonAfspeler: TToonAfspeler);
begin
  FToonAfspeler := aToonAfspeler;
end;

procedure TToonShapes.Clear;
begin
  Shapes.Clear;
end;

function TToonShapes.BepaalVerplaatsMode(aShape: TToonShape; aX, aY: Integer): TVerplaatsMode;
begin
  if aX > aShape.Rect.Right - 3 then
    Result := vmVerlengRechts
  else if aX < aShape.Rect.Left + 3 then
    Result := vmVerlengLinks
  else
    Result := vmVerplaats;
end;

function TToonShapes.AangewezenShape(aX, aY: Integer): TToonShape;
var
  myShape: TToonShape;
begin
  Result := nil;
  for myShape in Shapes do
    if (aX >= myShape.Rect.Left)
    and (aX <= myShape.Rect.Right)
    and (aY >= myShape.Rect.Top)
    and (aY <= myShape.Rect.Bottom) then
      Result := myShape;
end;

procedure TToonShapes.MouseDown(X, Y: Integer);
var
  myShape: TToonShape;
begin
  myShape := AangewezenShape(X, Y);
  if Assigned(FGeselecteerdeShape)
  and (myShape <> FGeselecteerdeShape) then
    InvalidateRect(FGeselecteerdeShape.Rect);

  FOpgepakteShape := myShape;
  if Assigned(FOpgepakteShape) then
  begin
    ToonGeselecteerd(FOpgepakteShape.Toon);
    FGeselecteerdeShape := FOpgepakteShape;
    SpeelToon(FOpgepakteShape.Toon);
    myShape := FGeselecteerdeShape;
    FBeginVerplaats.X := Round(X);
    FBeginVerplaats.Y := Round(Y);
    FBeginVerplaatsShapeRect := myShape.Rect;
  end
  else
  begin
    ChangeCursor(mycrDefault);
    myShape := FGeselecteerdeShape;
    FGeselecteerdeShape := nil;
  end;
  if Assigned(myShape) then
    InvalidateRect(myShape.Rect);
end;

procedure TToonShapes.MouseMove(X, Y: Integer);
var
  myShape: TToonShape;
  myDelta: TPoint;
  myHoogte: Byte;
begin
  if Assigned(FOpgepakteShape) then
  begin
    myDelta.X := Round(X)-FBeginVerplaats.X;
    myDelta.Y := Round(Y)-FBeginVerplaats.Y;
    InvalidateRect(FOpgepakteShape.Rect);
    if FVerplaatsMode in [vmVerlengLinks, vmVerplaats] then
      FOpgepakteShape.Rect.Left := FBeginVerplaatsShapeRect.Left   + myDelta.X;
    if FVerplaatsMode in [vmVerlengRechts, vmVerplaats] then
      FOpgepakteShape.Rect.Right := FBeginVerplaatsShapeRect.Right  + myDelta.X;
    if FVerplaatsMode = vmVerplaats then
    begin
      FOpgepakteShape.Rect.Top  := FBeginVerplaatsShapeRect.Top    + myDelta.Y;
      FOpgepakteShape.Rect.Bottom  := FBeginVerplaatsShapeRect.Bottom + myDelta.Y;
    end;
    InvalidateRect(FOpgepakteShape.Rect);
    myHoogte := FOpgepakteShape.Toon.Hoogte;
    FOpgepakteShape.BepaalEigenschappen;
    if myHoogte <> FOpgepakteShape.Toon.Hoogte then
      SpeelToon(FOpgepakteShape.Toon);
    ToonGeselecteerd(FOpgepakteShape.Toon);
  end
  else
  begin
    myShape := AangewezenShape(X, Y);
    if Assigned(myShape) then
    begin
      FVerplaatsMode := BepaalVerplaatsMode(myShape, X, Y);
      case FVerplaatsMode of
        vmVerlengLinks: ChangeCursor(mycrSizeWE);
        vmVerlengRechts: ChangeCursor(mycrSizeWE);
        vmVerplaats: ChangeCursor(mycrSizeAll);
      end;
    end
    else
      ChangeCursor(mycrDefault);
  end;
end;

procedure TToonShapes.MouseUp;
begin
  if Assigned(FOpgepakteShape) then
  begin
    InvalidateRect(FOpgepakteShape.Rect);
    FOpgepakteShape.BepaalEigenschappen;
    FOpgepakteShape.Resize;
    InvalidateRect(FOpgepakteShape.Rect);
    FOpgepakteShape := nil;
  end;
end;

procedure TToonShapes.InvalidateRect(aRect: TRect);
begin
  if Assigned(OnInvalidateRect) then
    OnInvalidateRect(aRect);
end;

procedure TToonShapes.ChangeCursor(aCursor: TMyCursor);
begin
  if Assigned(OnChangeCursor) then
    OnChangeCursor(aCursor)
end;

procedure TToonShapes.Lees(aToonLijst: TToonLijst);
var
  myToonShape: TToonShape;
  myToon: TToon;
begin
  for myToon in aToonlijst do
  begin
    myToonShape := TToonShape.Create(Self, myToon);
    Shapes.Add(myToonShape);
  end;
  ResizeShapes;
end;

procedure TToonShapes.ResizeShapes;
var
  myToonShape: TToonShape;
begin
  for myToonShape in Shapes do
    myToonShape.Resize;
end;

function TToonShapes.MaxMoment: TMoment;
var
  myShape: TToonShape;
begin
  Result := 0;
  for myShape in Shapes do
    if myShape.Toon.EindMoment > Result then
      Result := myShape.Toon.EindMoment;
end;

procedure TToonShapes.VerplaatsVerticaal(aDelta: Integer);
var
  myShape: TToonShape;
  H: Integer;
begin
  myShape := GeselecteerdeShape;
  if Assigned(myShape) then
  begin
    H := myShape.Toon.Hoogte+aDelta;
    if (H >= midiLaagsteToon)
    and (H <= midiHoogsteToon) then
    begin
      InvalidateRect(myShape.Rect);
      myShape.Toon.Hoogte := H;
      myShape.Resize;
      InvalidateRect(myShape.Rect);
      SpeelToon(myShape.Toon);
      ToonGeselecteerd(myShape.Toon);
    end;
  end;
end;

procedure TToonShapes.SpeelToon(aToon: TToon);
begin
  with aToon do
    FToonAfspeler.StartToon(KanaalNr, Hoogte, Velocity, (EindMoment-BeginMoment));
end;

procedure TToonShapes.ToonGeselecteerd(aToon: TToon);
begin
  if Assigned(OnToonGeselecteerd) then
    OnToonGeselecteerd(aToon);
end;

procedure TToonShapes.GetPositiesY(aToonhoogte: Byte; var YTop, YBottom: Integer);
begin
  with FShapeWerkruimte do
  begin
    YTop := (midiHoogsteToon-aToonHoogte-(OffsetVerticaal-midiLaagsteToon))*ShapeHoogte;
    YBottom := Round(YTop + ShapeHoogte);
  end;
end;

procedure TToonShapes.handleShapeWerkruimteGewijzigd;
begin
  ResizeShapes;
end;


{ TToonShape }
constructor TToonShape.Create(aOwner: TToonshapes; aToon: TToon);
begin
  inherited Create;
  Toon := aToon;
  FOwner := aOwner;
end;

function MulDiv(aNumber, aNumerator, aDenominator: Integer): Integer;
var
  myInt64: Int64;
begin
  myInt64 := aNumber * aNumerator;
  Result := myInt64 div aDenominator;
end;

procedure TToonShape.Resize;
begin
  with FOwner.FShapeWerkruimte do
  begin
    Rect.Left := GetX(Toon.BeginMoment);
    Rect.Right := GetX(Toon.EindMoment);
    Rect.Top := (midiHoogsteToon-Toon.Hoogte-(OffsetVerticaal-midiLaagsteToon))*ShapeHoogte;
    Rect.Bottom := Round(Rect.Top + ShapeHoogte);
  end;
end;

procedure TToonShape.BepaalEigenschappen;
var
  H, B, E: Integer;
begin
  with FOwner.FShapeWerkruimte do
  begin
    H := midiHoogsteToon - (OffsetVerticaal-midiLaagsteToon) - ((Rect.Top-(Rect.Top-Rect.Bottom) div 2) div ShapeHoogte);
    B := MulDiv(Rect.Left, MomentDivision, MomentBreedte) + OffsetHorizontaal;
    E := MulDiv(Rect.Right, MomentDivision, MomentBreedte) + OffsetHorizontaal;
  end;
  Toon.Hoogte := H;
  Toon.BeginMoment := B;
  Toon.EindMoment := E;
end;

end.

