unit uProcs;

interface

uses
  Classes, SysUtils,
{$ifdef Windows}
  Windows,
{$else}
  Types,
  lcltype,
{$endif}
  uTypes;

function MulDiv(aNumber, aNumerator, aDenominator: LongInt): LongInt;
function IntersectRect(const aRect1, aRect2: TRect): Boolean;
function MomentNaarStr(aMoment: TMoment; aDivision: word): String;
function ToonduurNaarStr(aToonduur: TMoment; aDivision: word): String;
function CompareMoment(aValue1, aValue2: TMoment): Integer;

implementation
uses
  Math;

function MulDiv(aNumber, aNumerator, aDenominator: LongInt): LongInt;
begin
  {$ifdef Windows}
  Result := Windows.MulDiv(aNumber, aNumerator, aDenominator);
  {$else}
  Result := lcltype.MulDiv(aNumber, aNumerator, aDenominator);
  {$endif}
end;

function IntersectRect(const aRect1, aRect2: TRect): Boolean;
var
  myRect: TRect;
begin
  myRect := Classes.Rect(0, 0, 0, 0);
  {$ifdef Windows}
  Result := Windows.IntersectRect(myRect, aRect1, aRect2);
  {$else}
  Result := Types.IntersectRect(myRect, aRect1, aRect2);
  {$endif}
end;

function MomentNaarStr(aMoment: TMoment; aDivision: word): String;
begin
  Result := Format('%d;%d', [aMoment div aDivision, aMoment mod aDivision]);
end;

function ToonduurNaarStr(aToonduur: TMoment; aDivision: word): String;
begin
  Result := Format('%d;%d', [aToonduur div aDivision, aToonduur mod aDivision]);
end;

function CompareMoment(aValue1, aValue2: TMoment): Integer;
begin
  Result := CompareValue(aValue1, aValue2);
end;

end.

