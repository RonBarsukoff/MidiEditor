unit cmpPanoramaChange;

interface

uses
  Classes, SysUtils,

  uTypes,
  cmpTrackElement,
  cmpObjectInfo,
  cmpSerializer;

type
  TPanoramaChange = class(TDataElement)
  protected
    procedure DefineSerializer(aSerializer: TSerializer); override;
  public
    Panorama: Byte;
    constructor Create(aTrack: TAbstractToonTrack; aKanaalNr: byte; aMoment: TMoment; aPanorama: Byte);
    function Soort: TSoortDataElement; override;
    function Data: byte; override;
    function Naam: String; override;
    procedure GetInfo(aInfo: TObjectInfo); override;
  end;

implementation

constructor TPanoramaChange.Create(aTrack: TAbstractToonTrack; aKanaalNr: byte; aMoment: TMoment; aPanorama: Byte);
begin
  inherited Create(aTrack, aKanaalNr, aMoment);
  Panorama := aPanorama;
end;

function TPanoramaChange.Soort: TSoortDataElement;
begin
  Result := sdePanorama;
end;

function TPanoramaChange.Data: byte;
begin
  Result := Panorama;
end;

function TPanoramaChange.Naam: String;
begin
  Result := 'Panorama';
end;

procedure TPanoramaChange.GetInfo(aInfo: TObjectInfo);
begin
  inherited GetInfo(aInfo);
  aInfo.AddItem('Waarde 1', 'Panorama');
  aInfo.AddItem('Waarde 2', IntToStr(Panorama));
end;

procedure TPanoramaChange.DefineSerializer(aSerializer: TSerializer);
begin
  inherited DefineSerializer(aSerializer);
  aSerializer.AddByte('Panorama', @Panorama);
end;

end.

