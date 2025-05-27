unit fMainModel;

interface
uses
  Classes,
  {$ifndef fpc}
  Types,
  {$endif}
  cmpToonAfspeler,
  cmpToonInspeler,
  uInstellingen,
  uCommonTypes;

type
  TfrmMainModel = class(TObject)
  private
    FInstellingen: TInstellingen;
    FToonAfspeler: TToonAfspeler;
    FToonInspeler: TToonInspeler;
    function getToonAfspelerOk: Boolean;
    function getToonAfspelerMelding: String;
    procedure handleToonAfspelerStatusUpdate(aOk: Boolean; const aMelding: String);
  public
    OnToonAfspelerStatusUpdate: TUpdateStatusEvent;
    constructor Create;
    procedure Init;
    destructor Destroy; override;
    procedure BewaarMidiInstellingen;
    procedure LaadMidiInstellingen;

    property Instellingen: TInstellingen read FInstellingen;
    property ToonAfspeler: TToonAfspeler read FToonAfspeler;
    property ToonInspeler: TToonInspeler read FToonInspeler;
    property ToonAfspelerOk: Boolean read getToonAfspelerOk;
    property ToonAfspelerMelding: String read getToonAfspelerMelding;
  end;

implementation
uses
  SysUtils,

  uMidiConstants;

constructor TfrmMainModel.Create;
begin
  inherited Create;
  FInstellingen := TInstellingen.Create;
  FToonAfspeler := TToonAfspeler.Create;
  FToonAfspeler.OnStatusUpdate := handleToonAfspelerStatusUpdate;
  FToonInspeler := TToonInspeler.Create;
end;

procedure TfrmMainModel.Init;
begin
  LaadMidiInstellingen;
  FToonAfspeler.Init(FInstellingen.MidiOutDevice);
end;

destructor TfrmMainModel.Destroy;
begin
  FToonAfspeler.Done;
  FToonAfspeler.Free;
  FToonInspeler.Done;
  FToonInspeler.Free;
  FInstellingen.Free;
  inherited Destroy;
end;

procedure TfrmMainModel.BewaarMidiInstellingen;
begin
  FInstellingen.BewaarMidiInstellingen;
  FToonAfspeler.Init(FInstellingen.MidiOutDevice);
end;

procedure TfrmMainModel.LaadMidiInstellingen;
begin
  FInstellingen.LaadMidiInstellingen;
end;

function TfrmMainModel.getToonAfspelerOk: Boolean;
begin
  Result := FToonAfspeler.OK;
end;

function TfrmMainModel.getToonAfspelerMelding: String;
begin
  Result := FToonAfspeler.Melding;
end;

procedure TfrmMainModel.handleToonAfspelerStatusUpdate(aOk: Boolean; const aMelding: String);
begin
  if Assigned(OnToonAfspelerStatusUpdate) then
    OnToonAfspelerStatusUpdate(aOk, aMelding);
end;

end.
