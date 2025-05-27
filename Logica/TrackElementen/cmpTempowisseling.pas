unit cmpTempoWisseling;

interface

uses
  Classes, SysUtils,

  uTypes,
  cmpTrackElement,
  cmpObjectInfo,
  cmpSerializer;

type
  TTempoWisseling = class(TTonenObjectElement)
  protected
    procedure DefineSerializer(aSerializer: TSerializer); override;
  public
    Tempo: Integer;
    constructor Create(aTonenObject: TAbstractTonenObject; aMoment: TMoment; aTempo: Integer); overload;
    procedure Init(aTonenObject: TAbstractTonenObject);
    procedure GetInfo(aInfo: TObjectInfo); override;
  end;

implementation

constructor TTempoWisseling.Create(aTonenObject: TAbstractTonenObject; aMoment: TMoment; aTempo: Integer);
begin
  inherited Create(aTonenObject, aMoment);
  Tempo := aTempo;
end;

procedure TTempoWisseling.Init(aTonenObject: TAbstractTonenObject);
begin
  FTonenObject := aTonenObject;
end;

procedure TTempoWisseling.DefineSerializer(aSerializer: TSerializer);
begin
  inherited DefineSerializer(aSerializer);
  aSerializer.AddInteger('Tempo', @Tempo);
end;

procedure TTempoWisseling.GetInfo(aInfo: TObjectInfo);
begin
  inherited GetInfo(aInfo);
  aInfo.AddItem('Tempo', IntToStr(Tempo));
end;

end.

