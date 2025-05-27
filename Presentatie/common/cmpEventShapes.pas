unit cmpEventShapes;
{$ifdef fpc}
{$mode DelphiUnicode}
{$endif}

interface

uses
  Classes, SysUtils,
  Generics.Collections,
  {$ifndef fpc}
  Types,
  {$endif}

  cmpObjectInfo,
  cmpTonenObject,
  cmpTrackElement,
  cmpShapes,
  cmpShapeWerkruimte;

type
  TEventShapes = class;
  TEventShape = class(TObject)
  private
    FOwner: TEventShapes;
  public
    Event: TDataElement;
    Rect: TRect;
    constructor Create(aOwner: TEventshapes; aEvent: TDataElement);
    procedure Resize;
  end;

  TEventShapeList = TObjectList<TEventShape>;

  TEventsGeselecteerdEvent = procedure(aObjectInfos: TObjectList<TObjectInfo>) of object;

  TEventShapes = class(TShapes)
  private
    FShapes: TEventShapeList;
    FAangewezenShapes: TEventShapeList;
    procedure handleShapeWerkruimteGewijzigd;
  protected
    procedure ResizeShapes; override;
  public
    OnEventsGeselecteerd: TEventsGeselecteerdEvent;
    constructor Create(aShapeWerkruimte: TShapeWerkruimte);
    destructor Destroy; override;
    procedure Clear;
    procedure Lees(aDataElementen: TDataElementen);
    procedure MouseDown(aX, aY: Integer);
    property Shapes: TEventShapeList read FShapes;
  end;

implementation
uses
  uTypes;

constructor TEventShapes.Create(aShapeWerkruimte: TShapeWerkruimte);
begin
  inherited Create(aShapeWerkruimte);
  FShapeWerkruimte.AddListener(handleShapeWerkruimteGewijzigd);
  FShapes := TEventShapeList.Create;
  FAangewezenShapes := TEventShapeList.Create(False);
end;

destructor TEventShapes.Destroy;
begin
  FShapeWerkruimte.RemoveListener(handleShapeWerkruimteGewijzigd);
  FShapes.Free;
  FAangewezenShapes.Free;
  inherited Destroy;
end;

procedure TEventShapes.Clear;
begin
  FShapes.Clear;
end;

procedure TEventShapes.Lees(aDataElementen: TDataElementen);
var
  myEventShape: TEventShape;
  myDataElement: TDataElement;
begin
  for myDataElement in aDataElementen do
  begin
    myEventShape := TEventShape.Create(Self, myDataElement);
    FShapes.Add(myEventShape);
  end;
  ResizeShapes;
end;

procedure TEventShapes.ResizeShapes;
var
  myShape: TEventShape;
begin
  for myShape in FShapes do
    myShape.Resize;
end;

procedure TEventShapes.handleShapeWerkruimteGewijzigd;
begin
  ResizeShapes;
end;

procedure TEventShapes.MouseDown(aX, aY: Integer);
var
  myShape: TEventShape;
  myObjectInfos: TObjectList<TObjectInfo>;
  myObjectInfo: TObjectInfo;
const
  EventNaam: array[TSoortDataElement] of String =
    ('Onbekend', 'Program change', 'Volume', 'Panorama', 'Pedaal');
begin
  if Assigned(OnEventsGeselecteerd) then
  begin
    myObjectInfos := TObjectList<TObjectInfo>.Create;
    try
      FAangewezenShapes.Clear;
      for myShape in Shapes do
        if (aX >= myShape.Rect.Left)
        and (aX <= myShape.Rect.Right)
        and (aY >= myShape.Rect.Top)
        and (aY <= myShape.Rect.Bottom) then
        begin
          FAangewezenShapes.Add(myShape);
          myObjectInfo := TObjectInfo.Create(EventNaam[myShape.Event.Soort]);
          myObjectInfos.Add(myObjectInfo);
          myShape.Event.GetInfo(myObjectInfo);
        end;
        OnEventsGeselecteerd(myObjectInfos);
    finally
      myObjectInfos.Free;
    end;
  end;
end;

{ TEventShape }
constructor TEventShape.Create(aOwner: TEventshapes; aEvent: TDataElement);
begin
  inherited Create;
  Event := aEvent;
  FOwner := aOwner;
end;

procedure TEventShape.Resize;
var
  myDuur: TMoment;
begin
  with FOwner.FShapeWerkruimte do
  begin
    Rect.Left := GetX(Event.BeginMoment);
    myDuur := MomentDivision div 4;
    if myDuur = 0 then { als de division heel klein is, zal normaal gesproken niet voorkomen }
      myDuur := MomentDivision;
    Rect.Right := GetX(Event.BeginMoment+myDuur); // ipv Rect.Left + 20;
    Rect.Top := ShapeHoogte*Event.KanaalNr+2;
    Rect.Bottom := Rect.Top+ShapeHoogte-2;
  end;
end;

end.

