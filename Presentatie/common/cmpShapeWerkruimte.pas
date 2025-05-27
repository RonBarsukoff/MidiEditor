unit cmpShapeWerkruimte;
{$ifdef fpc}
{$mode DelphiUnicode}
{$endif}

interface
uses
  Classes,
  Generics.Collections;

type
  TShapeWerkruimteGewijzigdEvent = procedure of object;

  TShapeWerkruimte = class(TObject)
  private
    FListeners: TList<TShapeWerkruimteGewijzigdEvent>;
    FMomentDivision: Integer;
    FOffsetHorizontaal: Integer;
    FOffsetVerticaal: Integer;
    FMomentBreedte: Integer;
    FShapeHoogte: Integer;
    procedure setOffsetHorizontaal(aValue: Integer);
    procedure setOffsetVerticaal(aValue: Integer);
    procedure setMomentBreedte(aValue: Integer);
    procedure setShapeHoogte(aValue: Integer);
    procedure NotifyListeners;
  public
    constructor Create;
    destructor Destroy; override;
    function GetX(aMoment: LongInt): Integer;
    procedure AddListener(aListener: TShapeWerkruimteGewijzigdEvent);
    procedure RemoveListener(aListener: TShapeWerkruimteGewijzigdEvent);
    procedure ResizeShapes;
    property MomentDivision: Integer read FMomentDivision write FMomentDivision;
    property OffsetHorizontaal: Integer read FOffsetHorizontaal write setOffsetHorizontaal;
    property OffsetVerticaal: Integer read FOffsetVerticaal write setOffsetVerticaal;
    property MomentBreedte:Integer read FMomentBreedte write setMomentBreedte;
    property ShapeHoogte: Integer read FShapeHoogte write setShapeHoogte;

  end;

implementation
uses
  uProcs;

constructor TShapeWerkruimte.Create;
begin
  inherited Create;
  FListeners := TList<TShapeWerkruimteGewijzigdEvent>.Create;
  ShapeHoogte := 10;
  MomentBreedte := 10;
  FMomentDivision := 0; // moet worden gezet tijdens het laden van een midifile
  OffsetVerticaal := 0;
end;

destructor TShapeWerkruimte.Destroy;
begin
  FListeners.Free;
  inherited Destroy;
end;

function TShapeWerkruimte.GetX(aMoment: LongInt): Integer;
begin
  Result := MulDiv((aMoment-OffsetHorizontaal), MomentBreedte, FMomentDivision);
end;

procedure TShapeWerkruimte.setOffsetHorizontaal(aValue: Integer);
begin
  FOffsetHorizontaal := aValue;
  NotifyListeners;
end;

procedure TShapeWerkruimte.setOffsetVerticaal(aValue: Integer);
begin
  FOffsetVerticaal := aValue;
  NotifyListeners;
end;

procedure TShapeWerkruimte.setMomentBreedte(aValue: Integer);
begin
  FMomentBreedte := aValue;
  NotifyListeners;
end;

procedure TShapeWerkruimte.setShapeHoogte(aValue: Integer);
begin
  FShapeHoogte := aValue;
  NotifyListeners;
end;

procedure TShapeWerkruimte.ResizeShapes;
begin
  NotifyListeners;
end;

procedure TShapeWerkruimte.NotifyListeners;
var
  myListener: TShapeWerkruimteGewijzigdEvent;
begin
  for myListener in FListeners do
    myListener;
end;

procedure TShapeWerkruimte.AddListener(aListener: TShapeWerkruimteGewijzigdEvent);
begin
  FListeners.Add(aListener);
end;

procedure TShapeWerkruimte.RemoveListener(aListener: TShapeWerkruimteGewijzigdEvent);
begin
  FListeners.Remove(aListener);
end;

end.
