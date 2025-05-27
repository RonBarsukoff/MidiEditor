unit cmpVolumeChange;

interface

uses
  Classes, SysUtils,

  uTypes,
  cmpObjectInfo,
  cmpTrackElement,
  cmpSerializer;

type
  TVolumeChange = class(TDataElement)
  protected
    procedure DefineSerializer(aSerializer: TSerializer); override;
  public
    Volume: Byte;
    constructor Create(aTrack: TAbstractToonTrack; aKanaalNr: byte; aMoment: TMoment; aVolume: Byte);
    function Soort: TSoortDataElement; override;
    function Data: byte; override;
    function Naam: String; override;
    procedure GetInfo(aInfo: TObjectInfo); override;
  end;

implementation

constructor TVolumeChange.Create(aTrack: TAbstractToonTrack; aKanaalNr: byte; aMoment: TMoment; aVolume: Byte);
begin
  inherited Create(aTrack, aKanaalNr, aMoment);
  Volume := aVolume;
end;

function TVolumeChange.Soort: TSoortDataElement;
begin
  Result := sdeVolume;
end;

function TVolumeChange.Data: byte;
begin
  Result := Volume;
end;

function TVolumeChange.Naam: String;
begin
  Result := 'Volume';
end;

procedure TVolumeChange.GetInfo(aInfo: TObjectInfo);
begin
  inherited GetInfo(aInfo);
  aInfo.AddItem('Waarde 1', 'Volume');
  aInfo.AddItem('Waarde 2', IntToStr(Volume));
end;

procedure TVolumeChange.DefineSerializer(aSerializer: TSerializer);
begin
  inherited DefineSerializer(aSerializer);
  aSerializer.AddByte('Volume', @Volume);
end;

end.

