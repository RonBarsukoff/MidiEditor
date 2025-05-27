unit cmpTrackElement;

interface
uses
  Classes, SysUtils,

  cmpSerializer,
  uTypes,
  uProcs,
  cmpObjectInfo;

type
  TAbstractToonTrack = class(TMyPersistent)
  public
    function TrackIndex: Integer; virtual; abstract;
    function Division: Integer; virtual; abstract;
  end;

  TAbstractTonenObject = class(TMyPersistent)
  protected
    function getDivision: Integer; virtual; abstract;
    procedure setDivision(aValue: Integer); virtual; abstract;
  public
    procedure Clear; virtual; abstract;
    function Tempo(aMoment: TMoment): Integer; virtual; abstract;
    function MomentNaarTijd(aMoment: TMoment): TTijd; virtual; abstract;
    function TrackIndexOf(aTrack: TAbstractToonTrack): Integer; virtual; abstract;
    property Division: Integer read getDivision write setDivision;
  end;

  TMomentElement = class(TMyPersistent)
  protected
    function getDivision: Integer; virtual; abstract;
  protected
    procedure DefineSerializer(aSerializer: TSerializer); override;
  public
    BeginMoment: TMoment;
    BeginTijd: TTijd; { wordt berekend voor bijvoorbeeld het afspelen of voor het
                        berekenen van het nieuwe moment als gevolg van een tempowisseling }
    constructor Create; overload;
    procedure GetInfo(aInfo: TObjectInfo); virtual;
    procedure Verplaats(aDelta: TDeltaMoment); virtual;
    property Division: Integer read getDivision;
  end;

  TTonenObjectElement = class(TMomentElement)
  protected
    FTonenObject: TAbstractTonenObject;
    function getDivision: Integer; override;
  public
    constructor Create(aTonenObject: TAbstractTonenObject; aMoment: TMoment); overload;
  end;

  TTrackElement = class(TMomentElement)
  protected
    FTrack: TAbstractToonTrack;
    function getDivision: Integer; override;
  public
    constructor Create(aTrack: TAbstractToonTrack; aMoment: TMoment); overload;
    procedure Init(aTrack: TAbstractToonTrack);
    property Track: TAbstractToonTrack read FTrack;
  end;

  TKanaalElement = class(TTrackElement)
  protected
    procedure DefineSerializer(aSerializer: TSerializer); override;
  public
    KanaalNr: Byte;
    function Naam: String; virtual; abstract;
    procedure GetInfo(aInfo: TObjectInfo); override;
  end;

  TSoortDataElement = (sdeOnbekend, sdeProgramChange, sdeVolume, sdePanorama, sdePedaal);

  TDataElement = class(TKanaalElement)
  protected
    procedure DefineSerializer(aSerializer: TSerializer); override;
  public
    constructor Create(aTrack: TAbstractToonTrack; aKanaalNr: byte; aMoment: TMoment); overload;
    function Naam: String; override;
    function Soort: TSoortDataElement; virtual;
    function Data: Byte; virtual;
  end;

implementation

procedure TMomentElement.DefineSerializer(aSerializer: TSerializer);
begin
  aSerializer.AddInteger('BeginMoment', @BeginMoment);
end;

constructor TMomentElement.Create;
begin
  inherited Create;
end;

procedure TMomentElement.GetInfo(aInfo: TObjectInfo);
begin
  aInfo.Clear;
  aInfo.AddItem('Moment', MomentNaarStr(BeginMoment, Division));
end;

procedure TMomentElement.Verplaats(aDelta: TDeltaMoment);
begin
  Inc(TDeltaMoment(BeginMoment), aDelta); // cast naar TDeltaMoment nodig voor fm
end;

constructor TTonenObjectElement.Create(aTonenObject: TAbstractTonenObject; aMoment: TMoment);
begin
  inherited Create;
  FTonenObject := aTonenObject;
  BeginMoment := aMoment;
end;

function TTonenObjectElement.getDivision: Integer;
begin
  Result := FTonenObject.Division;
end;

constructor TTrackElement.Create(aTrack: TAbstractToonTrack; aMoment: TMoment);
begin
  inherited Create;
  BeginMoment := aMoment;
  FTrack := aTrack;
end;

procedure TTrackElement.Init(aTrack: TAbstractToonTrack);
begin
  FTrack := aTrack;
end;

function TTrackElement.getDivision: Integer;
begin
  Result := FTrack.Division;
end;

constructor TDataElement.Create(aTrack: TAbstractToonTrack; aKanaalNr: byte; aMoment: TMoment);
begin
  inherited Create(aTrack, aMoment);
  KanaalNr := aKanaalNr;
  FTrack := aTrack;
end;

function TDataElement.Naam: String;
begin
  Result := 'DataElement';
end;

function TDataElement.Soort: TSoortDataElement;
begin
  Result := sdeOnbekend;
end;

function TDataElement.Data: Byte;
begin
  Result := 0;
end;

procedure TDataElement.DefineSerializer(aSerializer: TSerializer);
begin
  inherited DefineSerializer(aSerializer);
  aSerializer.WriteClassName := True;
end;

procedure TKanaalElement.DefineSerializer(aSerializer: TSerializer);
begin
  inherited DefineSerializer(aSerializer);
  aSerializer.AddByte('Kanaal', @KanaalNr);
end;

procedure TKanaalElement.GetInfo(aInfo: TObjectInfo);
begin
  inherited GetInfo(aInfo);
  aInfo.AddItem('Kanaal', KanaalNr);
end;

end.

