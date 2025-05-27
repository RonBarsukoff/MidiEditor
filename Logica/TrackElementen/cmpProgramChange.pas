unit cmpProgramChange;

interface
uses
  Classes, SysUtils,

  uTypes,
  cmpObjectInfo,
  cmpTrackElement,
  cmpSerializer;

  type
  TProgramChange = class(TDataElement)
  protected
    procedure DefineSerializer(aSerializer: TSerializer); override;
  public
    Instrument: Byte;
    constructor Create(aTrack: TAbstractToonTrack; aKanaalNr: byte; aMoment: TMoment; aInstrument: Byte);
    function Soort: TSoortDataElement; override;
    function Data: byte; override;
    function Naam: String; override;
    procedure GetInfo(aInfo: TObjectInfo); override;
  end;

implementation
uses
  uMidiConstants;

constructor TProgramChange.Create(aTrack: TAbstractToonTrack; aKanaalNr: byte; aMoment: TMoment; aInstrument: Byte);
begin
inherited Create(aTrack, aKanaalNr, aMoment);
  Instrument := aInstrument;
end;

function TProgramChange.Soort: TSoortDataElement;
begin
  Result := sdeProgramChange;
end;

function TProgramChange.Data: byte;
begin
  Result := Instrument;
end;

function TProgramChange.Naam: String;
begin
  Result := 'Instrument';
end;

procedure TProgramChange.GetInfo(aInfo: TObjectInfo);
begin
  inherited GetInfo(aInfo);
  aInfo.AddItem('Waarde 1', 'Instrument');
  aInfo.AddItem('Waarde 2', MidiInstrumentNaam[Instrument]);
end;

procedure TProgramChange.DefineSerializer(aSerializer: TSerializer);
begin
  inherited DefineSerializer(aSerializer);
  aSerializer.AddByte('Instrument', @Instrument);
end;

end.

