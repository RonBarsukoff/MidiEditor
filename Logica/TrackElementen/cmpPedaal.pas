unit cmpPedaal;

interface

uses
  Classes, SysUtils,

  uTypes,
  cmpObjectInfo,
  cmpTrackElement,
  cmpSerializer;

type
  TPedaal = class(TDataElement)
  protected
    procedure DefineSerializer(aSerializer: TSerializer); override;
  public
    Neer: Boolean;
    constructor Create(aTrack: TAbstractToonTrack; aKanaalNr: byte; aMoment: TMoment; aNeer: Boolean); overload;
    function Naam: String; override;
    function Soort: TSoortDataElement; override;
    function Data: byte; override;
    procedure GetInfo(aInfo: TObjectInfo); override;
  end;

implementation

constructor TPedaal.Create(aTrack: TAbstractToonTrack; aKanaalNr: byte; aMoment: TMoment; aNeer: Boolean);
begin
  inherited Create(aTrack, aKanaalNr, aMoment);
  Neer := aNeer;
end;

function TPedaal.Naam: String;
begin
  Result := 'Pedaal';
end;

function TPedaal.Soort: TSoortDataElement;
begin
  Result := sdePedaal;
end;

function TPedaal.Data: byte;
begin
  if Neer then
    Result := 127
  else
    Result := 0;
end;

procedure TPedaal.GetInfo(aInfo: TObjectInfo);
const
  Tekst: array[Boolean] of String = ('Los', 'Neer');
begin
  inherited GetInfo(aInfo);
  aInfo.AddItem('Waarde 1', 'Pedaal');
  aInfo.AddItem('Waarde 2', Tekst[Neer]);
end;

procedure TPedaal.DefineSerializer(aSerializer: TSerializer);
begin
  inherited DefineSerializer(aSerializer);
  aSerializer.AddBoolean('Neer', @Neer);
end;

end.

