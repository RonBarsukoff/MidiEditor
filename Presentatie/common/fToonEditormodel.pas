unit fToonEditorModel;
{$ifdef fpc}
{$mode DelphiUnicode}
{$endif}

interface
uses
  Classes,
  {$ifndef fpc}
  Types,
  {$endif}
  Generics.Collections,

  uTypes,
  cmpStrings2D,
  cmpShapeWerkruimte,
  cmpToon,
  cmpToonAfspeler,
  cmpToonInspeler,
  cmpToonShapes,
  cmpEventShapes,
  cmpAfspeler,
  uInstellingen,
  cmpTonenObject,
  fMainModel,
  cmpObjectInfo;

type
  TTekenShapeParams = record
    Rect: TRect;
    GeselecteerdeShape: Boolean;
    TrackIndex: Integer;
  end;

  TTekenBaanParams = record
    Top,
    Bottom,
    ToonHoogte: Integer;
  end;

  TTekenLiniaalParams = record
    X: Integer;
    Moment: Integer;
    Division: Integer;
    Init: Boolean;   // true bij de eerste aanroep, moment heeft dan nog geen waarde
    TekenAangewezenMoment: Boolean;
  end;

  TAfspelerStatusParams = record
    X: Integer;
    Moment: TMoment;
    Gestart,
    Gepauzeerd: Boolean;
  end;

  TTekenShapeEvent = procedure(const aParams: TTekenShapeParams) of object;
  TTekenBaanEvent = procedure(const aParams: TTekenBaanParams) of object;
  TTekenLiniaalEvent = procedure(const aParams: TTekenLiniaalParams) of object;
  TAfspelerStatusEvent = procedure(const aParams: TAfspelerStatusParams) of object;
  TMeldingEvent = procedure(const aMelding: String) of object;
  TToonGeselecteerdEvent = procedure(const aToonInfo: TObjectInfo) of object;

  TfrmToonEditorModel = class(TObject)
  private
    FFileName: String;
    FTonenObject: TTonenObject;
    FInstellingen: TInstellingen;
    FToonShapes: TToonShapes;
    FEventShapes: TEventShapes;
    FAfspeler: TAfspeler;
    FToonAfspeler: TToonAfspeler; // niet de owner
    FToonInspeler: TToonInspeler; // niet de owner
    FShapeWerkruimte: TShapeWerkRuimte;
    FAangewezenMoment: TMoment;
    procedure Invalidate;
    procedure HandleInvalidateRect(aRect: TRect);
    procedure HandleChangeCursor(aCursor: TMyCursor);
    procedure HandleToonGeselecteerd(const aToon: TToon);
    procedure HandleEventsGeselecteerd(aObjectInfos: TObjectList<TObjectInfo>);

    function getTrackZichtbaar(aTrackIndex: Integer): Boolean;
    procedure setTrackZichtbaar(aTrackIndex: Integer; aValue: Boolean);
    function getMaxMoment: Integer;
    function getAantalTracks: Integer;
    function getTracknaam(aTrackIndex: Integer): String;
    procedure handleAfspelerStatusUpdate(const  aAfspeelStatus: TAfspeelStatus);
    procedure GeefMelding(aMelding: String);
  public
    OnInvalidate: TNotifyEvent;
    OnInvalidateRect: TInvalidateRectEvent;
    OnChangeCursor: TChangeCursorEvent;
    OnTekenToonShape: TTekenShapeEvent;
    OnTekenEventShape: TTekenShapeEvent;
    OnTekenBaan: TTekenBaanEvent;
    OnTekenLiniaal: TTekenLiniaalEvent;
    OnToonGeselecteerd: TToonGeselecteerdEvent;
    OnEventsGeselecteerd: TEventsGeselecteerdEvent;
    OnAfspelerStatus: TAfspelerStatusEvent;
    OnMelding: TMeldingEvent;
    OnLiniaalInvalidated: TNotifyEvent;
    constructor Create;
    procedure Init(aFilename: String; aMainModel: TfrmMainModel);
    procedure Done;
    destructor Destroy; override;
    procedure OpenBestand(aFileName: String);
    procedure BewaarAls(const aFilename: String);
    procedure BewaarAlsMidiBestand(const aFilename: String);
    function MidiDivision: Integer;
    procedure VulToonTekstLijst(aLijst: TStrings2D; aTrackIndex: Integer);
    procedure VulEventTekstLijst(aLijst: TStrings2D; aTrackIndex: Integer);
    procedure VulStemLijst(aLijst: TStrings);
    procedure VulTempoWisselingen(aStrings: TStrings2D);
    procedure LeesTonenObject;
    procedure ScrollHorizontaal(aPosition: Integer);
    procedure ScrollVerticaal(aPosition: Integer);
    procedure ZoomVerticaal(aGroter: Boolean);
    procedure ZoomHorizontaal(aGroter: Boolean);
    procedure ToonShapesMouseDown(X, Y: Integer);
    procedure EventShapesMouseDown(X, Y: Integer);
    procedure MouseUp;
    procedure MouseMove(X, Y: Integer);
    procedure TekenLiniaal(const aRect: TRect);
    procedure TekenToonShapes(const aRect: TRect);
    procedure TekenTrackEvents(const aRect: TRect);
    procedure VerplaatsVerticaal(aDelta: Integer);
    procedure GetPositiesY(aToonhoogte: Byte; var YTop, YBottom: Integer);
    procedure StopAfspelen;
    procedure StartAfspelen;
    function AfspelenGestart: Boolean;
    procedure VerplaatsAangewezenMoment(aNaarMoment: TMoment);

    property Instellingen: TInstellingen read FInstellingen;
    property TrackZichtbaar[aTrackIndex: Integer]: Boolean read getTrackZichtbaar write setTrackZichtbaar;
    property MaxMoment: Integer read getMaxMoment;
    property AantalTracks: Integer read getAantalTracks;
    property Tracknaam[aTrackIndex: Integer]: String read getTracknaam;
    property TonenObject: TTonenObject read FTonenObject;
    property FileName: String read FFileName;
    property AangewezenMoment: TMoment read FAangewezenMoment;

  end;

implementation
uses
  SysUtils,

  uProcs,
  uMidiConstants,
  cmpMidiObject,
  cmpMidiSchrijver,
  cmpMidiObjectNaarTonenObjectConverter,
  cmpTrackElement,
  cmpTempoWisseling;

constructor TfrmToonEditorModel.Create;
begin
  inherited Create;
  FShapeWerkRuimte := TShapeWerkRuimte.Create;
  FTonenObject := TTonenObject.Create;
  FToonShapes := TToonShapes.Create(FShapeWerkRuimte);
  FEventShapes := TEventShapes.Create(FShapeWerkRuimte);
  FAfspeler := TAfspeler.Create(FTonenObject);
  FAfspeler.OnStatusUpdate := handleAfspelerStatusUpdate;
end;

procedure TfrmToonEditorModel.Init(aFilename: String; aMainModel: TfrmMainModel);
begin
  FFilename := aFilename;
  FInstellingen := aMainModel.Instellingen;
  FToonAfspeler := aMainModel.ToonAfspeler;
  FToonInspeler := aMainModel.ToonInspeler;
  FToonShapes.Init(FToonAfspeler);
  FToonShapes.OnInvalidateRect := HandleInvalidateRect;
  FToonShapes.OnChangeCursor := HandleChangeCursor;
  FToonShapes.OnToonGeselecteerd := HandleToonGeselecteerd;
  FEventShapes.OnEventsGeselecteerd := HandleEventsGeselecteerd;
end;

procedure TfrmToonEditorModel.Done;
begin
  if AfspelenGestart then
    FAfspeler.Stop;
  FToonAfspeler.Done;
end;

destructor TfrmToonEditorModel.Destroy;
begin
  FAfspeler.Free;
  FToonShapes.Free;
  FEventShapes.Free;
  FTonenObject.Free;
  FShapeWerkRuimte.Free;
  inherited Destroy;
end;

procedure TfrmToonEditorModel.OpenBestand(aFileName: String);
var
  S: String;
  F: TStringStream;
begin
  F := TStringStream.Create;
  try
    F.LoadFromFile(aFilename);
    S := F.Datastring;
    FTonenObject.LoadFromSerializedString(S);
    FTonenObject.Init;
  finally
    F.Free;
  end;
end;

procedure TfrmToonEditorModel.BewaarAls(const aFilename: String);
var
  S: String;
  F: TStringStream;
begin
  S := FTonenObject.ToSerializedString;
  F := TStringStream.Create;
  try
    F.WriteString(S);
    F.SaveToFile(aFilename);
  finally
    F.Free;
  end;
end;

procedure TfrmToonEditorModel.BewaarAlsMidiBestand(const aFilename: String);
var
  mySchrijver: TMidiSchrijver;
  myMidiConverter: TMidiConverter;
  myMidiObject: TMidiObject;
begin
  myMidiObject := TMidiObject.Create;
  try
    myMidiConverter := TMidiConverter.Create;
    try
      myMidiConverter.TonenNaarMidi(myMidiObject, FTonenObject);
    finally
      myMidiConverter.Free;
    end;
    mySchrijver := TMidiSchrijver.Create(myMidiObject);
    try
      mySchrijver.Schrijf(aFileName);
      FFileName := aFileName;
    finally
      mySchrijver.Free;
    end;
  finally
    myMidiObject.Free;
  end;
end;

function TfrmToonEditorModel.MidiDivision: Integer;
begin
  Result := FTonenObject.Division;
end;

procedure VerwerkInfo(aInfo: TObjectInfo; aLijst: TStrings2D; aRij: Integer);
var
  myKolom: Integer;
begin
  if aRij = 0 then
  begin
    aLijst.AantalKolommen := aInfo.ItemCount;
    for myKolom := 0 to aInfo.ItemCount-1 do
      aLijst.Header[myKolom] := aInfo.GetItem(myKolom).Naam;
  end;
  for myKolom := 0 to aInfo.ItemCount-1 do
    aLijst[myKolom, aRij] := aInfo.GetItem(myKolom).Waarde;
end;

procedure TfrmToonEditorModel.VulToonTekstLijst(aLijst: TStrings2D; aTrackIndex: Integer);
var
  myToon: TToon;
  myInfo: TObjectInfo;
  myRij: Integer;
begin
  myInfo := TObjectInfo.Create('Toon');
  try
    aLijst.Clear;
    aLijst.AantalRijen := FTonenObject.Tracks[aTrackIndex].ToonLijst.Count;
    myRij := 0;
    for myToon in FTonenObject.Tracks[aTrackIndex].ToonLijst do
    begin
      myToon.GetInfo(myInfo);
      VerwerkInfo(myInfo, aLijst, myRij);
      Inc(myRij);
    end;
  finally
    myInfo.Free;
  end;
end;

procedure TfrmToonEditorModel.VulEventTekstLijst(aLijst: TStrings2D; aTrackIndex: Integer);
var
  myElement: TKanaalElement;
  myInfo: TObjectInfo;
  myRij: Integer;
begin
  myInfo := TObjectInfo.Create('Event');
  try
    aLijst.Clear;
    if Assigned(FTonenObject.Tracks[aTrackIndex].DataElementen) then
    begin
      aLijst.AantalRijen := FTonenObject.Tracks[aTrackIndex].DataElementen.Count;
      myRij := 0;
      for myElement in FTonenObject.Tracks[aTrackIndex].DataElementen do
      begin
        myElement.GetInfo(myInfo);
        VerwerkInfo(myInfo, aLijst, myRij);
        Inc(myRij);
      end;
    end;
  finally
    myInfo.Free;
  end;
end;

procedure TfrmToonEditorModel.VulStemLijst(aLijst: TStrings);
var
  myToonTrack: TToonTrack;
begin
  aLijst.Clear;
  for myToonTrack in FTonenObject.Tracks do
    if Assigned(myToonTrack.ToonLijst) then
    aLijst.Add(Format('%s (%d)', [myToonTrack.Naam, myToonTrack.ToonLijst.Count]));
end;

procedure TfrmToonEditorModel.VulTempoWisselingen(aStrings: TStrings2D);
var
  myTempoWisseling: TTempoWisseling;
  myRij,
    myKolom: Integer;
  myInfo: TObjectInfo;
begin
  aStrings.Clear;
  aStrings.AantalRijen := FTonenObject.TempoWisselingen.Count;
  aStrings.AantalKolommen := 2;
  myRij := 0;
  myInfo := TObjectInfo.Create('Tempowisseling');
  try
    for myTempoWisseling in FTonenObject.TempoWisselingen do
    begin
      myTempoWisseling.GetInfo(myInfo);
      if myRij = 0 then
      begin
        aStrings.AantalKolommen := myInfo.ItemCount;
        for myKolom := 0 to myInfo.ItemCount-1 do
          aStrings.Header[myKolom] := myInfo.GetItem(myKolom).Naam;
      end;
      for myKolom := 0 to myInfo.ItemCount-1 do
        aStrings[myKolom, myRij] := myInfo.GetItem(myKolom).Waarde;
      //aStrings[0, myRij] := IntToStr(myTempoWisseling.BeginMoment);
      //aStrings[1, myRij] := IntToStr(myTempoWisseling.Tempo);
      Inc(myRij);
    end;
  finally
    myInfo.Free;
  end;
end;

procedure TfrmToonEditorModel.LeesTonenObject;
var
  myTrack: TToonTrack;
  I: Integer;
begin
  FToonShapes.Clear;
  FEventShapes.Clear;
  FShapeWerkruimte.MomentDivision := FTonenObject.Division;
  for I := 0 to FTonenObject.Tracks.Count-1 do
  begin
    myTrack := FTonenObject.Tracks[I];
    if Assigned(myTrack.ToonLijst) then
      FToonshapes.Lees(myTrack.ToonLijst);
    if Assigned(myTrack.DataElementen) then
      FEventshapes.Lees(myTrack.DataElementen);
    FToonshapes.TrackZichtbaar[I] := True;
    FEventshapes.TrackZichtbaar[I] := True;
  end;
  Invalidate;
end;

procedure TfrmToonEditorModel.Invalidate;
begin
  if Assigned(OnInvalidate) then
    OnInvalidate(nil);
end;

procedure TfrmToonEditorModel.HandleInvalidateRect(aRect: TRect);
begin
  if Assigned(OnInvalidateRect) then
    OnInvalidateRect(aRect);
end;

procedure TfrmToonEditorModel.HandleChangeCursor(aCursor: TMyCursor);
begin
  if Assigned(OnChangeCursor) then
    OnChangeCursor(aCursor);
end;

procedure TfrmToonEditorModel.handleToonGeselecteerd(const aToon: TToon);
var
  myToonInfo: TObjectInfo;
begin
  if Assigned(OnToonGeselecteerd) then
  begin
    myToonInfo := TObjectInfo.Create('Toon');
    try
      aToon.GetInfo(myToonInfo);
      OnToonGeselecteerd(myToonInfo);
      if CompareMoment(aToon.BeginMoment, FAangewezenMoment) <> 0 then
      begin
        FAangewezenMoment := aToon.BeginMoment;
        if Assigned(OnLiniaalInvalidated) then
          OnLiniaalInvalidated(Self);
      end;
    finally
      myToonInfo.Free;
    end;
  end;
end;


procedure TfrmToonEditorModel.HandleEventsGeselecteerd(aObjectInfos: TObjectList<TObjectInfo>);
begin
  if Assigned(OnEventsGeselecteerd) then
    OnEventsGeselecteerd(aObjectInfos);
end;

function TfrmToonEditorModel.getTrackZichtbaar(aTrackIndex: Integer): Boolean;
begin
  Result := FToonShapes.TrackZichtbaar[aTrackIndex];
end;

procedure TfrmToonEditorModel.setTrackZichtbaar(aTrackIndex: Integer; aValue: Boolean);
begin
  FToonShapes.TrackZichtbaar[aTrackIndex] := aValue;
  FEventShapes.TrackZichtbaar[aTrackIndex] := aValue;
end;

function TfrmToonEditorModel.getMaxMoment: Integer;
begin
  Result := FToonShapes.MaxMoment;
end;

function TfrmToonEditorModel.getAantalTracks: Integer;
begin
  Result := FTonenObject.Tracks.Count;
end;

function TfrmToonEditorModel.getTracknaam(aTrackIndex: Integer): String;
begin
  Result := FTonenObject.Tracks[aTrackIndex].Naam;
end;

procedure TfrmToonEditorModel.ZoomVerticaal(aGroter: Boolean);
var
  myHoogte: Integer;
begin
  if aGroter then
    myHoogte := FShapeWerkruimte.ShapeHoogte + 1
  else
    myHoogte := FShapeWerkruimte.ShapeHoogte - 1;
  if (myHoogte >= 1) and (myHoogte <= 50) then
  begin
    FShapeWerkruimte.ShapeHoogte := myHoogte;
    Invalidate;
  end;
end;

procedure TfrmToonEditorModel.ZoomHorizontaal(aGroter: Boolean);
var
  myBreedte: Integer;
begin
  if aGroter then
    myBreedte := FShapeWerkruimte.MomentBreedte + 1
  else
    myBreedte := FShapeWerkruimte.MomentBreedte - 1;
  if (myBreedte >= 1) and (myBreedte <= 50) then
  begin
    FShapeWerkruimte.MomentBreedte := myBreedte;
    Invalidate;
  end;
end;


procedure TfrmToonEditorModel.ToonShapesMouseDown(X, Y: Integer);
begin
  FToonShapes.MouseDown(X, Y);
end;

procedure TfrmToonEditorModel.EventShapesMouseDown(X, Y: Integer);
begin
  FEventShapes.MouseDown(X, Y);
end;

procedure TfrmToonEditorModel.MouseUp;
begin
  FToonShapes.MouseUp;
end;

procedure TfrmToonEditorModel.MouseMove(X, Y: Integer);
begin
  FToonShapes.MouseMove(X, Y);
end;

procedure TfrmToonEditorModel.ScrollHorizontaal(aPosition: Integer);
begin
  FShapeWerkruimte.OffsetHorizontaal := aPosition;
  Invalidate;
end;

procedure TfrmToonEditorModel.ScrollVerticaal(aPosition: Integer);
begin
  FShapeWerkruimte.OffsetVerticaal := aPosition;
  Invalidate;
end;

procedure TfrmToonEditorModel.TekenLiniaal(const aRect: TRect);
var
  I: Integer;
  myMaxMoment: Integer;
  myLiniaalParams: TTekenLiniaalParams;
begin
  if Assigned(OnTekenLiniaal)
  and (FToonShapes.Werkruimte.MomentDivision > 0) then
  begin
    myLiniaalParams.Init := True;
    OnTekenLiniaal(myLiniaalParams);
    myLiniaalParams.Init := False;
    myLiniaalParams.TekenAangewezenMoment := False;
    if FTonenObject.Division > 0 then
    begin
      myMaxMoment := FToonShapes.MaxMoment;
      I := 0;
      while I <= myMaxMoment do
      begin
        myLiniaalParams.X := FToonShapes.Werkruimte.GetX(I);
        myLiniaalParams.Moment := I;
        myLiniaalParams.Division := FToonShapes.Werkruimte.MomentDivision;
        OnTekenLiniaal(myLiniaalParams);
        Inc(I, FTonenObject.Division);
      end;
    end;
    myLiniaalParams.TekenAangewezenMoment := True;
    myLiniaalParams.X := FToonShapes.Werkruimte.GetX(FAangewezenMoment);
    myLiniaalParams.Moment := FAangewezenMoment;
    OnTekenLiniaal(myLiniaalParams);
  end;
end;

procedure TfrmToonEditorModel.TekenToonShapes(const aRect: TRect);
var
  myToonShape: TToonShape;
  myBaanParams: TTekenBaanParams;
  myShapeParams: TTekenShapeParams;
  I: Integer;
begin
  if Assigned(OnTekenBaan) then
  begin
    for I := midiLaagsteToon to midiHoogsteToon do
    begin
      myBaanParams.Toonhoogte := I;
      GetPositiesY(I, myBaanParams.Top, myBaanParams.Bottom);
      OnTekenBaan(myBaanParams);
    end;
  end;

  for myToonShape in FToonShapes.Shapes do
  begin
    myShapeParams.TrackIndex := myToonShape.Toon.Track.TrackIndex;
    if FToonShapes.TrackZichtbaar[myShapeParams.TrackIndex] then
    begin
      if uProcs.IntersectRect(myToonShape.Rect, aRect) then
      begin
        myShapeParams.Rect := myToonShape.Rect;
        myShapeParams.GeselecteerdeShape := myToonShape = FToonShapes.GeselecteerdeShape;
        OnTekenToonShape(myShapeParams);
      end;
    end;
  end;
end;

procedure TfrmToonEditorModel.TekenTrackEvents(const aRect: TRect);
var
  myEventShape: TEventShape;
  myShapeParams: TTekenShapeParams;
begin
  for myEventShape in FEventShapes.Shapes do
  begin
    myShapeParams.TrackIndex := myEventShape.Event.Track.TrackIndex;
    if FEventShapes.TrackZichtbaar[myShapeParams.TrackIndex] then
    begin
      if uProcs.IntersectRect(myEventShape.Rect, aRect) then
      begin
        myShapeParams.Rect := myEventShape.Rect;
        myShapeParams.GeselecteerdeShape := False; //myEventShape = FEventShapes.GeselecteerdeShape;
        OnTekenEventShape(myShapeParams);
      end;
    end;
  end;
end;

procedure TfrmToonEditorModel.VerplaatsVerticaal(aDelta: Integer);
begin
  FToonShapes.VerplaatsVerticaal(aDelta);
end;

procedure TfrmToonEditorModel.GetPositiesY(aToonhoogte: Byte; var YTop, YBottom: Integer);
begin
  FToonShapes.GetPositiesY(aToonhoogte, YTop, YBottom);
end;

procedure TfrmToonEditorModel.StopAfspelen;
begin
  FAfspeler.Stop;
  FToonAfspeler.Init(FInstellingen.MidiOutDevice);
end;

procedure TfrmToonEditorModel.Startafspelen;
begin
  FToonAfspeler.Done;
  FAfspeler.Start(FInstellingen.MidiOutDevice);
  if not AfspelenGestart then
    GeefMelding(FAfspeler.LastResult);
end;

function TfrmToonEditorModel.AfspelenGestart: Boolean;
begin
  Result := FAfspeler.Gestart;
end;

procedure TfrmToonEditorModel.VerplaatsAangewezenMoment(aNaarMoment: TMoment);
begin
  FTonenObject.VerplaatsMoment(AangewezenMoment, aNaarMoment);
  FShapeWerkruimte.ResizeShapes;
  Invalidate;
end;

procedure TfrmToonEditorModel.handleAfspelerStatusUpdate(const  aAfspeelStatus: TAfspeelStatus);
var
  myParams: TAfspelerStatusParams;
begin
  if Assigned(OnAfspelerStatus) then
  begin
    myParams.Gestart := aAfspeelStatus.Gestart;
    myParams.Gepauzeerd := aAfspeelStatus.Gepauzeerd;
    myParams.Moment := aAfspeelStatus.Moment;
    myParams.X := FToonShapes.Werkruimte.GetX(aAfspeelStatus.Moment);
    OnAfspelerStatus(myParams);
  end;
end;

procedure TfrmToonEditorModel.GeefMelding(aMelding: String);
begin
  if Assigned(OnMelding) then
    OnMelding(aMelding);
end;

end.
