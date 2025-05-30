unit cmpSerializedObject;

interface

uses
  Classes, SysUtils,

{$ifdef fpc}
  fpJson
{$else}
  Json
{$endif}
;

type
{$ifdef fpc}
  TSerializedValue = TJsonData;
  TSerializedObject = fpJson.TJsonObject;
  TSerializedArray = fpJson.TJsonArray;
{$else}
  TSerializedValue = Json.TJsonValue;
  TSerializedObject = Json.TJsonObject;
  TSerializedObjectHelper = class helper for Json.TJsonObject
  public
    function Find(aNaam: String): TSerializedValue;
  end;
  TSerializedArray = Json.TJsonArray;
{$endif}

  TSerializedObjectContainer = class(TObject)
  private
    FJsonObject: TSerializedObject;
    JsonObjectCreated: Boolean;
    function GetArrays(aName : String): TSerializedArray;
    function GetBooleans(aName : String): Boolean;
    function GetFloats(aName : String): Double;
    function GetIntegers(aName : String): Integer;
    function GetObjects(aName : String): TSerializedObject;
    function GetStrings(aName : String): String;

    function GetCount: Integer;
    function GetNameOf(aIndex : Integer): String;
  public
    constructor Create(aJsonObject: TSerializedObject);
    destructor Destroy; override;
    function AsString: String;

    procedure Add(const AName: String; AValue: Boolean); overload;
    procedure Add(const AName: String; AValue: Double); overload;
    procedure Add(const AName: String; AValue: String); overload;
    procedure Add(const AName: String; Avalue: Integer); overload;
    procedure Add(const AName: String; AValue : TSerializedArray); overload;
    procedure Add(const AName: String; AValue : TSerializedObject); overload;

    property Arrays[aName : String] : TSerializedArray Read GetArrays;
    property Booleans[aName : String] : Boolean Read GetBooleans;
    Property Floats[aName : String] : Double Read GetFloats;
    Property Integers[aName : String] : Integer Read GetIntegers;
    property Objects[aName : String] : TSerializedObject Read GetObjects;
    property Strings[aName : String] : String Read GetStrings;

    property Count: Integer read getCount;
    property Names[aIndex : Integer] : String read GetNameOf;
    property SerializedObject: TSerializedObject read FJsonObject;
  end;

  function StringNaarSerializedObject(aString: String): TSerializedObjectContainer;

implementation
{$ifndef fpc}
uses
  System.Generics.Collections;
{$endif}

constructor TSerializedObjectContainer.Create(aJsonObject: TSerializedObject);
begin
  inherited Create;
  FJsonObject := aJsonObject;
end;

destructor TSerializedObjectContainer.Destroy;
begin
  if JsonObjectCreated then
    SerializedObject.Free;
  inherited Destroy;
end;

function TSerializedObjectContainer.GetArrays(aName : String): TSerializedArray;
begin
{$ifdef fpc}
  Result := FJsonObject.Arrays[aName];
{$else}
  Result := FJsonObject.Get(aName).JsonValue.AsType<TJSONArray>;
{$endif}
end;

function TSerializedObjectContainer.GetBooleans(aName : String): Boolean;
begin
{$ifdef fpc}
  Result := FJsonObject.Booleans[aName];
{$else}
  Result := FJsonObject.Get(aName).JsonValue.AsType<Boolean>;
{$endif}
end;

function TSerializedObjectContainer.GetFloats(aName : String): Double;
begin
{$ifdef fpc}
  Result := FJsonObject.Floats[aName];
{$else}
  Result := FJsonObject.Get(aName).JsonValue.AsType<Double>;
{$endif}
end;

function TSerializedObjectContainer.GetIntegers(aName : String): Integer;
begin
{$ifdef fpc}
  Result := FJsonObject.Integers[aName];
{$else}
  Result := FJsonObject.Get(aName).JsonValue.AsType<Integer>;
{$endif}
end;

function TSerializedObjectContainer.GetObjects(aName : String): TSerializedObject;
begin
{$ifdef fpc}
  Result := FJsonObject.Objects[aName];
{$else}
  Result := FJsonObject.Get(aName).JsonValue.AsType<TSerializedObject>;
{$endif}
end;

function TSerializedObjectContainer.GetStrings(aName : String): String;
begin
{$ifdef fpc}
  Result := FJsonObject.Strings[aName];
{$else}
  Result := FJsonObject.Get(aName).JsonValue.AsType<String>;
{$endif}
end;

function TSerializedObjectContainer.AsString: String;
begin
{$ifdef fpc}
  Result := FJsonObject.AsJson;
{$else}
  Result := FJsonObject.ToJson([]);
{$endif}
end;

function TSerializedObjectContainer.GetCount: Integer;
begin
  Result := FJsonObject.Count;
end;

function TSerializedObjectContainer.GetNameOf(aIndex : Integer): String;
begin
{$ifdef fpc}
  Result := FJsonObject.Names[aIndex];
{$else}
  Result := FJsonObject.Pairs[aIndex].JsonString.AsType<String>;
{$endif}
end;

procedure TSerializedObjectContainer.Add(const AName: String; AValue: Boolean);
begin
{$ifdef fpc}
  FJsonObject.Add(aName, aValue);
{$else}
  FJsonObject.AddPair(TJsonPair.Create(aName, TJsonBool.Create(aValue)));
{$endif}
end;

procedure TSerializedObjectContainer.Add(const AName: String; AValue: Double);
begin
{$ifdef fpc}
  FJsonObject.Add(aName, aValue);
{$else}
  FJsonObject.AddPair(TJsonPair.Create(aName, TJsonNumber.Create(aValue)));
{$endif}
end;

procedure TSerializedObjectContainer.Add(const AName: String; AValue: String);
begin
{$ifdef fpc}
  FJsonObject.Add(aName, aValue);
{$else}
  FJsonObject.AddPair(TJsonPair.Create(aName, TJsonString.Create(aValue)));
{$endif}
end;

procedure TSerializedObjectContainer.Add(const AName: String; Avalue: Integer);
begin
{$ifdef fpc}
  FJsonObject.Add(aName, aValue);
{$else}
  FJsonObject.AddPair(TJsonPair.Create(aName, TJsonNumber.Create(aValue)));
{$endif}
end;

procedure TSerializedObjectContainer.Add(const AName: String; AValue : TSerializedArray);
begin
{$ifdef fpc}
  FJsonObject.Add(aName, aValue);
{$else}
  FJsonObject.AddPair(TJsonPair.Create(aName, aValue));
{$endif}
end;

procedure TSerializedObjectContainer.Add(const AName: String; AValue : TSerializedObject);
begin
{$ifdef fpc}
  FJsonObject.Add(aName, aValue);
{$else}
  FJsonObject.AddPair(TJsonPair.Create(aName, aValue));
{$endif}
end;

function StringNaarSerializedObject(aString: String): TSerializedObjectContainer;
var
  myValue: TSerializedValue;
begin
{$ifdef fpc}
  myValue := GetJson(aString);
{$else}
  myValue := TSerializedObject.ParseJSONValue(aString);
{$endif}
  Result := TSerializedObjectContainer.Create(myValue as TSerializedObject);
  Result.JsonObjectCreated := True;
end;

{$ifndef fpc}
function TSerializedObjectHelper.Find(aNaam: String): TSerializedValue;
var
  myPair: TJsonPair;
begin
  myPair := Get(aNaam);
  if Assigned(myPair) then
    Result := myPair.JsonValue
  else
    Result := nil;
end;
{$endif}

end.

