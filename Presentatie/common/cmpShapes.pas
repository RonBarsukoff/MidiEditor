unit cmpShapes;

interface

uses
  Classes, SysUtils,
  cmpShapeWerkruimte;

type
  TVerplaatsMode = (vmGeen, vmVerlengLinks, vmVerlengRechts, vmVerplaats);

  TShapes = class(TObject)
  protected
    FVerplaatsMode: TVerplaatsMode;
    FShapeWerkruimte: TShapeWerkRuimte;
    FZichtbareTracks: array[byte] of Boolean;
    function getTrackZichtbaar(aTrackIndex: Integer): Boolean;
    procedure setTrackZichtbaar(aTrackIndex: Integer; aValue: Boolean);
  protected
    procedure ResizeShapes; virtual; abstract;
  public
    constructor Create(aShapeWerkruimte: TShapeWerkruimte);
    destructor Destroy; override;
    property Werkruimte: TShapeWerkRuimte read FShapeWerkRuimte;
    property TrackZichtbaar[aTrackIndex: Integer]: Boolean read getTrackZichtbaar write setTrackZichtbaar;
  end;

implementation

constructor TShapes.Create(aShapeWerkruimte: TShapeWerkruimte);
begin
  inherited Create;
  FShapeWerkRuimte := aShapeWerkRuimte;
end;

destructor TShapes.Destroy;
begin
  inherited Destroy;
end;

function TShapes.getTrackZichtbaar(aTrackIndex: Integer): Boolean;
begin
  Result := FZichtbareTracks[aTrackIndex];
end;

procedure TShapes.setTrackZichtbaar(aTrackIndex: Integer; aValue: Boolean);
begin
  FZichtbareTracks[aTrackIndex] := aValue;
end;

end.

