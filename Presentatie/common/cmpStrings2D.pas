unit cmpStrings2D;
{$ifdef fpc}
{$mode DelphiUnicode}
{$endif}

interface

uses
  Classes, SysUtils;

type

  TStrings2D = class(TObject)
  private
    FRijen: array of array of String;
    FHeaders: array of String;
    function getAantalRijen: Integer;
    procedure setAantalRijen(aWaarde: Integer);
    function getAantalKolommen: Integer;
    procedure setAantalKolommen(aWaarde: Integer);
    function getCelWaarde(aKolom, aRij: Integer): String;
    procedure setCelWaarde(aKolom, aRij: Integer; aWaarde: String);
    function getHeader(aKolom: Integer): String;
    procedure setHeader(aKolom: Integer; aWaarde: String);
  public
    constructor Create;
    procedure Clear;
    property AantalRijen: Integer read getAantalRijen write setAantalRijen;
    property AantalKolommen: Integer read getAantalKolommen write setAantalKolommen;
    property CelWaarde[aKolom, aRij: Integer]: String read getCelWaarde write setCelWaarde; default;
    property Header[aKolom: Integer]: String read getHeader write setHeader;
  end;

implementation

constructor TStrings2D.Create;
begin
  inherited Create;
  Clear;
end;

procedure TStrings2D.Clear;
begin
  SetLength(FRijen, 1);
  SetLength(FRijen[0], 1);
  CelWaarde[0, 0] := '';
  SetLength(FHeaders, 1);
end;

function TStrings2D.getAantalRijen: Integer;
begin
  Result := Length(FRijen);
end;

procedure TStrings2D.setAantalRijen(aWaarde: Integer);
var
  I,
  myOldValue: Integer;
begin
  myOldValue := AantalRijen;
  SetLength(FRijen, aWaarde);
  for I := myOldValue to aWaarde-1 do
    SetLength(FRijen[I], AantalKolommen);
end;

function TStrings2D.getAantalKolommen: Integer;
begin
  Result := Length(FRijen[0]);
end;

procedure TStrings2D.setAantalKolommen(aWaarde: Integer);
var
  I: Integer;
begin
  for I := 0 to AantalRijen-1 do
    SetLength(FRijen[I], aWaarde);
  SetLength(FHeaders, aWaarde);
end;

function TStrings2D.getCelWaarde(aKolom, aRij: Integer): String;
begin
  Result := FRijen[aRij][aKolom];
end;

procedure TStrings2D.setCelWaarde(aKolom, aRij: Integer; aWaarde: String);
begin
  FRijen[aRij][aKolom] := aWaarde;
end;

function TStrings2D.getHeader(aKolom: Integer): String;
begin
  Result := FHeaders[aKolom];
end;

procedure TStrings2D.setHeader(aKolom: Integer; aWaarde: String);
begin
  FHeaders[aKolom] := aWaarde;
end;

end.

