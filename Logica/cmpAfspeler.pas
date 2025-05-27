unit cmpAfspeler;

interface

uses
  Classes, SysUtils,   ExtCtrls,
  { MidiEditor }
  uTypes,
  cmpToon,
  cmpAfspeellijst,
  uMidiDevices,
  uMidiOutDevice,
  cmpTonenObject;

type
  TAfspeelStatus = record
    Gestart,
    Gepauzeerd: Boolean;
    Moment: TMoment;
  end;

  TAfspelerStatusUpdate = procedure(const aAfspeelStatus: TAfspeelStatus) of Object;

  TAfspeler = class(TObject)
  private
    FGestart,
    FGepauzeerd: Boolean;
    FTonenObject: TTonenObject;
    FAfspeelLijst: TAfspeelLijst;
    FLastResult: String;
    FMidiDevice: TMidiOutDevice;
    FMidiDevices: TMidiDevices;

    FStartTijd: TTijd;
    FCurrentAfspeelEventIndex: Integer;
    FTimer: TTimer;
    function GetTime: TTijd;
    procedure MaakAfspeellijst;
    procedure UpdateStatus(aMoment: TMoment);
    procedure handleTimer(aSender: TObject);
  public
    OnStatusUpdate: TAfspelerStatusUpdate;
    constructor Create(aTonenObject: TTonenObject);
    destructor Destroy; override;
    procedure Start(const aMidiOutDevice: String);
    procedure GaVerder;
    procedure Pauzeer;
    procedure Stop;
    property Gestart: Boolean read FGestart;
    property LastResult: String read FLastResult;
  end;

implementation
uses
  uMidiDeviceFactory,
  cmpAfspeelEvent,
  cmpTrackElement;

constructor TAfspeler.Create(aTonenObject: TTonenObject);
begin
  inherited Create;
  FTonenObject := aTonenObject;
  FAfspeelLijst := TAfspeelLijst.Create;
  FMidiDevices := CreateMidiDevices;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := 10;
end;

destructor TAfspeler.Destroy;
begin
  FTimer.Free;
  FAfspeelLijst.Free;
  FMidiDevices.Free;
  inherited Destroy;
end;

procedure TAfspeler.Start(const aMidiOutDevice: String);
begin
  FMidiDevice := FMidiDevices.GetOutDevice(aMidiOutDevice);
  if Assigned(FMidiDevice) then
  begin
    FMidiDevice.IsOpen := True;
    if FMidiDevice.IsOpen then
    begin
      MaakAfspeellijst;
      FGestart := True;
      FCurrentAfspeelEventIndex := 0;
      GaVerder;
    end
    else
      FLastResult := FMidiDevice.LastResult;
  end;
end;

procedure TAfspeler.GaVerder;
begin
  FGepauzeerd := False;
  FStartTijd := GetTime;
  FTimer.OnTimer := HandleTimer;
  FTimer.Enabled := True;
  UpdateStatus(0);
end;

procedure TAfspeler.Stop;
begin
  Pauzeer;
  FMidiDevice.IsOpen := False;
  FLastResult := FMidiDevice.LastResult;
  FGestart := False;
  UpdateStatus(0);
end;

procedure TAfspeler.Pauzeer;
begin
  if FTimer.Enabled then
    FTimer.Enabled := False;
  FGepauzeerd := True;
  UpdateStatus(0);
end;

procedure TAfspeler.MaakAfspeellijst;
var
  myTrack: TToonTrack;
  myToon: TToon;
  myDataElement: TDataElement;
begin
  FAfspeelLijst.StartMaakLijst;
  for myTrack in FTonenObject.Tracks do
  begin
    myTrack.BerekenTijden;
    for myToon in myTrack.ToonLijst do
      with myToon do
      begin
        FAfspeelLijst.ToevoegenNootAan(BeginTijd, BeginMoment, KanaalNr, Hoogte, Velocity);
        FAfspeelLijst.ToevoegenNootUit(EindTijd, EindMoment, KanaalNr, Hoogte);
      end;
    for myDataElement in myTrack.DataElementen do
      with myDataElement do
        if myDataElement.Soort = sdeProgramChange then
          FAfspeelLijst.ToevoegenProgramChangeElement(BeginTijd, BeginMoment, KanaalNr, Data)
        else
          FAfspeelLijst.ToevoegenControlChangeElement(BeginTijd, BeginMoment, KanaalNr, Soort, Data);
  end;
  FAfspeelLijst.EindeMaakLijst;
end;

procedure TAfspeler.handleTimer(aSender: TObject);
var
  myAfspeelEvent: TAfspeelEvent;
  myAfspeelEventDetail: TAfspeelEventDetail;
  myKanaalAfspeelEvent: TKanaalAfspeelEvent;
  //myOutMessage: LongInt;
  myHuidigeTijd,
  myAfspeelTijd: TTijd;
begin
  if FCurrentAfspeelEventIndex > FAfspeelLijst.AfspeelEvents.Count -1 then
    Pauzeer
  else
  begin
    myAfspeelEvent := FAfspeelLijst.AfspeelEvents[FCurrentAfspeelEventIndex];
    myAfspeelTijd := myAfspeelEvent.Tijd;
    myHuidigeTijd := GetTime - FStartTijd;
    if myAfspeelTijd <= myHuidigeTijd then
    begin
      UpdateStatus(myAfspeelEvent.Moment);
      for myAfspeelEventDetail in myAfspeelEvent.Events do
      begin
        myKanaalAfspeelEvent := myAfspeelEventDetail as TKanaalAfspeelEvent;
        if myKanaalAfspeelEvent.Soort = saeNootAan then
          FMidiDevice.ToonAan(myKanaalAfspeelEvent.Kanaal, myKanaalAfspeelEvent.Hoogte, 100)
        else if myKanaalAfspeelEvent.Soort = saeNootUit then
          FMidiDevice.ToonAan(myKanaalAfspeelEvent.Kanaal, myKanaalAfspeelEvent.Hoogte, 0)

        //myOutMessage := myAfspeelEventDetail.Param;
        //FMidiDevice.SendShortMessage(myOutMessage);
        //if myOutMessage > 0 then
        //  midiOutShortMsg(FUitHandle, myOutMessage);
      end;
      Inc(FCurrentAfspeelEventIndex);
    end;
  end;
end;

procedure TAfspeler.UpdateStatus(aMoment: TMoment);
var
  myAfspeelStatus: TAfspeelStatus;
begin
  if Assigned(OnStatusUpdate) then
  begin
    myAfspeelStatus.Gestart := FGestart;
    myAfspeelStatus.Gepauzeerd := FGepauzeerd;
    myAfspeelStatus.Moment := aMoment;
    OnStatusUpdate(myAfspeelStatus)
  end;
end;

function TAfspeler.GetTime: TTijd;
var
  myFrac: Double;
begin
  myFrac := Frac(Now);
  Result := Trunc(myFrac*24*60*60*1000);
end;

end.

