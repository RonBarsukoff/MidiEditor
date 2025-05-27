unit cmpTonenObject;

{$ifdef fpc}
{$mode DelphiUnicode}
{$endif}

interface

uses
  Classes, SysUtils,
  Generics.Collections,

  cmpSerializer,
  cmpSerializedObject,
  uTypes,
  cmpToon,
  cmpTrackElement,
  cmpTempoWisseling;

type
  TToonLijst = TObjectList<TToon>;
  TDataElementen = TObjectList<TDataElement>;
  TTempoWisselingen = TObjectList<TTempoWisseling>;

  TToonTrack = class(TAbstractToonTrack)
  private
    FOwner: TAbstractTonenObject;
  public
    Naam: String;
    ToonLijst: TToonlijst;
    DataElementen: TDataElementen;
    constructor Create; overload;
    constructor Create(aOwner: TAbstractTonenObject); overload;
    procedure Init(aOwner: TAbstractTonenObject);
    destructor Destroy; override;
    procedure DefineSerializer(aSerializer: TSerializer); override;
    function VindClass(aClassName: String): TClass; override;
    function TrackIndex: Integer; override;
    function Division: Integer; override;
    procedure BerekenTijden; // berekent van alle elementen in ToonLijst en DataElementen de tijd
    procedure VerplaatsMoment(aVanMoment, aNaarMoment: TMoment);
    property Owner: TAbstractTonenObject read FOwner write FOwner;
  end;

  TToonTracks = class(TMyPersistent)
  private
    FItems: TObjectList<TToonTrack>;
  public
    constructor Create;
    procedure Init(aOwner: TAbstractTonenObject);
    destructor Destroy; override;
    procedure Clear;
    procedure DefineSerializer(aSerializer: TSerializer); override;
    property Items: TObjectList<TToonTrack> read FItems;
  end;

  TTonenObject = class(TAbstractTonenObject)
  private
    FDivision: Integer;
    FTracks: TToonTracks;
    FTempoWisselingen: TTempoWisselingen;
    function getTracks: TObjectList<TToonTrack>;
  protected
    function getDivision: Integer; override;
    procedure setDivision(aValue: Integer); override;
    procedure DefineSerializer(aSerializer: TSerializer); override;
  public
    constructor Create;
    procedure CreateObjecten;
    procedure Init;
    destructor Destroy; override;
    procedure Clear; override;
    function Tempo(aMoment: TMoment): Integer; override;
    function MomentNaarTijd(aMoment: TMoment): TTijd; override;
    function TrackIndexOf(aTrack: TAbstractToonTrack): Integer; override;
    procedure VerplaatsMoment(aVanMoment, aNaarMoment: TMoment);

    property Tracks: TObjectList<TToonTrack> read getTracks;
    property TempoWisselingen: TTempoWisselingen read FTempoWisselingen;
  end;

implementation
uses
  uProcs,
  cmpVolumeChange,
  cmpProgramChange,
  cmpPanoramaChange,
  cmpPedaal;

constructor TTonenObject.Create;
begin
  inherited Create;
  Division := 48;
end;

procedure TTonenObject.CreateObjecten;
begin
  FTracks := TToonTracks.Create;
  FTempoWisselingen := TTempoWisselingen.Create;
end;

procedure TTonenObject.Init;
var
  myTempoWisseling: TTempoWisseling;
begin
  FTracks.Init(Self);
  if Assigned(FTempoWisselingen) then
    for myTempoWisseling in FTempoWisselingen do
      myTempoWisseling.Init(Self);

end;

destructor TTonenObject.Destroy;
begin
  FTempoWisselingen.Free;
  FTracks.Free;
  inherited Destroy;
end;

procedure TTonenObject.Clear;
begin
  FTracks.Clear;
end;

function TTonenObject.getTracks: TObjectList<TToonTrack>;
begin
  Result := FTracks.Items;
end;

function TTonenObject.Tempo(aMoment: TMoment): Integer;
var
  I: Integer;
begin
  Result := 100;
  I := 0;
  while (I <= FTempoWisselingen.Count-1)
  and (FTempoWisselingen[I].BeginMoment <= aMoment) do
  begin
    Result := FTempoWisselingen[I].Tempo;
    Inc(I);
  end;
end;

const
  MilliSecPerMin = 60000;

function TTonenObject.MomentNaarTijd(aMoment: TMoment): TTijd;
var
  myMoment: TMoment;
  I: Integer;
begin
  //bereken de tijd van de laatste maatwisseling waarvan het moment voor aMoment ligt
  Result := 0;
  myMoment := 0;
  I := 0;
  while (I <= FTempoWisselingen.Count-1)
  and (FTempoWisselingen[I].BeginMoment < aMoment) do
  begin
    Result := Result + MulDiv(MilliSecPerMin, FTempoWisselingen[I].BeginMoment-myMoment, Tempo(myMoment)*Division);
    myMoment := FTempoWisselingen[I].BeginMoment;
    Inc(I);
  end;
  // verhoog de tijd met het deel vanaf de laatste maatwisseling
  Result := Result + MulDiv(MilliSecPerMin, aMoment-myMoment, Tempo(myMoment)*Division);
end;

function TTonenObject.TrackIndexOf(aTrack: TAbstractToonTrack): Integer;
begin
  Result := Tracks.IndexOf(aTrack as TToonTrack);
end;

function TTonenObject.getDivision: Integer;
begin
  Result := FDivision;
end;

procedure TTonenObject.setDivision(aValue: Integer);
begin
  FDivision := aValue;
end;

procedure TTonenObject.DefineSerializer(aSerializer: TSerializer);
begin
  aSerializer.AddObjectList<TTempoWisseling>('TempoWisselingen', @FTempoWisselingen);
  aSerializer.AddInteger('Division', @FDivision);
  aSerializer.AddObject('Tracks', @FTracks, TToonTracks);
end;

procedure TTonenObject.VerplaatsMoment(aVanMoment, aNaarMoment: TMoment);
var
  myTrack: TToonTrack;
begin
  for myTrack in FTracks.Items do
    myTrack.VerplaatsMoment(aVanMoment, aNaarMoment);
end;

{ TToonTrack }
constructor TToonTrack.Create;
begin
  inherited Create;
end;

constructor TToonTrack.Create(aOwner: TAbstractTonenObject);
begin
  inherited Create;
  FOwner := aOwner;
  ToonLijst := TToonlijst.Create;
  DataElementen := TDataElementen.Create;
end;

procedure TToonTrack.Init(aOwner: TAbstractTonenObject);
var
  myElement: TTrackElement;
begin
  FOwner := aOwner;
  if Assigned(Toonlijst) then
    for myElement in Toonlijst do
      myElement.Init(Self);
  if Assigned(DataElementen) then
    for myElement in DataElementen do
      myElement.Init(Self);
end;

destructor TToonTrack.Destroy;
begin
  ToonLijst.Free;
  DataElementen.Free;
  inherited Destroy;
end;

procedure TToonTrack.DefineSerializer(aSerializer: TSerializer);
begin
  aSerializer.AddString('Naam', @Naam);
  aSerializer.AddObjectList<TToon>('Toonlijst', @Toonlijst);
  aSerializer.AddObjectList<TDataElement>('DataElementen', @DataElementen);
end;

function TToonTrack.VindClass(aClassName: String): TClass;
begin
  if aClassName = 'TToon' then
    Result := TToon
  else if aClassName = 'TVolumeChange' then
    Result := TVolumeChange
  else if aClassName = 'TProgramChange' then
    Result := TProgramChange
  else if aClassName = 'TPanoramaChange' then
    Result := TPanoramaChange
  else if aClassName = 'TPedaal' then
    Result := TPedaal
  else
    Result := nil;
end;

function TToonTrack.TrackIndex: Integer;
begin
  Result := FOwner.TrackIndexOf(Self);
end;

function TToonTrack.Division: Integer;
begin
  Result := FOwner.Division;
end;

procedure TToonTrack.BerekenTijden; // berekent van alle elementen in ToonLijst en DataElementen de tijd
var
  myToon: TToon;
  myDataElement: TDataElement;
begin
  for myToon in ToonLijst do
  begin
    myToon.BeginTijd := FOwner.MomentNaarTijd(myToon.BeginMoment);
    myToon.EindTijd := FOwner.MomentNaarTijd(myToon.EindMoment);
  end;
  for myDataElement in DataElementen do
    myDataElement.BeginTijd := FOwner.MomentNaarTijd(myDataElement.BeginMoment);
end;

procedure TToonTrack.VerplaatsMoment(aVanMoment, aNaarMoment: TMoment);
var
  myElement: TKanaalElement;
  myDelta: TDeltaMoment;
begin
  myDelta := TDeltaMoment(aNaarMoment)-TDeltaMoment(aVanMoment);
  for myElement in ToonLijst do
    if myElement.BeginMoment >= aVanMoment then
      myElement.Verplaats(myDelta);
  for myElement in DataElementen do
    if myElement.BeginMoment >= aVanMoment then
      myElement.Verplaats(myDelta);
end;

{ TToonTracks }
constructor TToonTracks.Create;
begin
  inherited Create;
  FItems := TObjectList<TToonTrack>.Create;
end;

procedure TToonTracks.Init(aOwner: TAbstractTonenObject);
var
  myTrack: TToonTrack;
begin
  for myTrack in FItems do
    myTrack.Init(aOwner);
end;

destructor TToonTracks.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TToonTracks.Clear;
begin
  FItems.Clear;
end;

procedure TToonTracks.DefineSerializer(aSerializer: TSerializer);
begin
  aSerializer.AddObjectList<TToonTrack>('Items', @FItems);
end;

end.

