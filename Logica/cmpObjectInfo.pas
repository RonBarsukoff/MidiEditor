unit cmpObjectInfo;
{$ifdef fpc}
{$mode DelphiUnicode}
{$endif}

interface

uses
  Classes, SysUtils,
  Generics.Collections;

type
  TObjectInfoItem = class(TObject)
    Naam: String;
    Waarde: String;
    constructor Create(aNaam, aWaarde: String);
  end;

  TObjectInfo = class(TObject)
  private
    FItems: TObjectList<TObjectInfoItem>;
    FNaam: String;
  public
    constructor Create(aNaam: String);
    destructor Destroy; override;
    procedure Clear;
    function ItemCount: Integer;
    function GetItem(aIndex: Integer): TObjectInfoItem;
    function WaardenAlsTekst: String;
    procedure AddItem(aKey, aValue: String); overload;
    procedure AddItem(aKey: String; aValue: Integer); overload;
    property Naam: String read FNaam;
  end;

implementation

constructor TObjectInfo.Create(aNaam: String);
begin
  inherited Create;
  FNaam := aNaam;
  FItems := TObjectList<TObjectInfoItem>.Create;
end;

destructor TObjectInfo.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TObjectInfo.Clear;
begin
  FItems.Clear;
end;

function TObjectInfo.ItemCount: Integer;
begin
  Result := FItems.Count;
end;

function TObjectInfo.GetItem(aIndex: Integer): TObjectInfoItem;
begin
  Result := FItems[aIndex];
end;

function TObjectInfo.WaardenAlsTekst: String;
var
  myItem: TObjectInfoItem;
begin
  Result := '';
  for myItem in FItems do
    if Result = '' then
      Result := Result + myItem.Waarde
    else
      Result := Result + ' ' + myItem.Waarde
end;

procedure TObjectInfo.AddItem(aKey, aValue: String);
begin
  FItems.Add(TObjectInfoItem.Create(aKey, aValue));
end;

procedure TObjectInfo.AddItem(aKey: String; aValue: Integer);
begin
  FItems.Add(TObjectInfoItem.Create(aKey, IntToStr(aValue)));
end;

constructor TObjectInfoItem.Create(aNaam, aWaarde: String);
begin
  inherited Create;
  Naam := aNaam;
  Waarde := aWaarde;
end;

end.

