unit cmpToon;

interface
uses
  Classes,
  uTypes,
  cmpTrackElement,
  cmpObjectInfo,
  cmpSerializer;

type
  TToon = class(TKanaalElement)
  protected
    procedure DefineSerializer(aSerializer: TSerializer); override;
  public
    Hoogte,
    Velocity: byte;
    EindMoment: TMoment;
    EindTijd: TTijd;
    constructor Create(aTrack: TAbstractToonTrack; aKanaalNr, aHoogte, aVelocity: byte; aBeginMoment, aEindMoment: TMoment); overload;
    procedure GetInfo(aInfo: TObjectInfo); override;
    function Naam: String; override;
    procedure Verplaats(aDelta: TDeltaMoment); override;
  end;

implementation
uses
  SysUtils,

  uProcs,
  uMidiConstants;

constructor TToon.Create(aTrack: TAbstractToonTrack; aKanaalNr, aHoogte, aVelocity: byte; aBeginMoment, aEindMoment: TMoment);
begin
  inherited Create(aTrack, aBeginMoment);
  KanaalNr := aKanaalNr;
  Hoogte := aHoogte;
  Velocity := aVelocity;
  BeginMoment := aBeginMoment;
  EindMoment := aEindMoment;
end;

procedure TToon.DefineSerializer(aSerializer: TSerializer);
begin
  inherited DefineSerializer(aSerializer);
  aSerializer.AddInteger('EindMoment', @EindMoment);
  aSerializer.AddByte('Hoogte', @Hoogte);
  aSerializer.AddByte('Velocity', @Velocity);
end;

procedure TToon.GetInfo(aInfo: TObjectInfo);
begin
  inherited GetInfo(aInfo);
  aInfo.AddItem('Lengte', ToonduurNaarStr(EindMoment-BeginMoment, FTrack.Division));
  aInfo.AddItem('Hoogte', ToonhoogteAlsTekst(Hoogte));
  aInfo.AddItem('Velocity', Velocity);
end;

function TToon.Naam: String;
begin
  Result := 'Toon';
end;

procedure TToon.Verplaats(aDelta: TDeltaMoment);
begin
  inherited Verplaats(aDelta);
  Inc(TDeltaMoment(EindMoment), aDelta);
end;

end.
