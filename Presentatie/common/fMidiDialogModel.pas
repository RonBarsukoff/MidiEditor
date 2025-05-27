unit fMidiDialogModel;

interface
uses
  Classes,
  uCommonTypes,
  uMidiDevices,
  cmpToonAfspeler,
  cmpToonInspeler;

type
  TfrmMidiDialogModel = class(TObject)
  private
    FTestToonIndex: Integer;
    FToonAfspeler: TToonAfspeler;
    FToonInspeler: TToonInspeler;
    FMidiDevices: TMidiDevices;
    procedure HandleToonEvent(aToon: TAfspeelToon);
  public
    OnToonEvent: TToonInEvent;
    constructor Create;
    procedure Init(aToonAfspeler: TToonAfspeler; aToonInspeler: TToonInspeler);
    destructor Destroy; override;
    procedure TestMidiOut(aAan: Boolean; const aMidiOutDevice: String = '');
    procedure TestMidiIn(aAan: Boolean; const aMidiInDevice: String = '');
    procedure VolgendeToon;
    procedure LeesInDevices(aItems: TStrings);
    procedure LeesOutDevices(aItems: TStrings);
    property MidiDevices: TMidiDevices read FMidiDevices;
  end;

implementation
uses
  SysUtils,
  uMidiDeviceFactory;

constructor TfrmMidiDialogModel.Create;
begin
  inherited Create;
  FMidiDevices := CreateMidiDevices;
end;

procedure TfrmMidiDialogModel.Init(aToonAfspeler: TToonAfspeler; aToonInspeler: TToonInspeler);
begin
  FToonAfspeler := aToonAfspeler;
  FToonInspeler := aToonInspeler;
end;

destructor TfrmMidiDialogModel.Destroy;
begin
  TestMidiOut(False);
  FMidiDevices.Free;
  inherited Destroy;
end;

procedure TfrmMidiDialogModel.TestMidiOut(aAan: Boolean; const aMidiOutDevice: String = '');
begin
  if aAan then
  begin
    FToonAfspeler.Init(aMidiOutDevice);
    FTestToonIndex := 1;
  end
  else
  FToonAfspeler.StopToon;
end;

procedure TfrmMidiDialogModel.VolgendeToon;
const
  Toonhoogtes: array[1..14] of integer =
    (60, 62, 64, 65, 67, 69, 71, 72, 71, 69, 67, 65, 64, 62);
begin
  FToonAfspeler.StartToon(0, ToonHoogtes[FTestToonIndex], 100, 300);
  Inc(FTestToonIndex);
  if FTestToonIndex > High(ToonHoogtes) then
    FTestToonIndex := 1;
end;

procedure TfrmMidiDialogModel.LeesInDevices(aItems: TStrings);
begin
  FMidiDevices.LeesInDevices;
  aItems.Assign(FMidiDevices.InDeviceList);
end;

procedure TfrmMidiDialogModel.LeesOutDevices(aItems: TStrings);
begin
  FMidiDevices.LeesOutDevices;
  aItems.Assign(FMidiDevices.OutDeviceList);
end;

procedure TfrmMidiDialogModel.TestMidiIn(aAan: Boolean; const aMidiInDevice: String = '');
begin
  if aAan then
  begin
    FToonInspeler.Init(aMidiInDevice);
    FToonInspeler.OnToonEvent := handleToonEvent;
  end
  else
  begin
    FToonInspeler.Done;
  end;
end;

procedure TfrmMidiDialogModel.HandleToonEvent(aToon: TAfspeelToon);
begin
  if Assigned(OnToonEvent) then
    OnToonEvent(aToon);
end;

end.
