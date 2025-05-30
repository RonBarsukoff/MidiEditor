unit cmpSerializer;

{$ifdef fpc}
{$mode DelphiUnicode}
{$endif}

interface

uses
  Classes, SysUtils,
  Generics.Collections,

  cmpSerializedObject;

type
  MyPString = ^String;

  TSerializer = class;

  PMyPersistent = ^TMyPersistent;
  TMyPersistentClass = class of TMyPersistent;

  TMyPersistent = class(TObject)
  private
    FClassName: String;
    function PGetSerializedObject: TSerializedObject;
    procedure PLoadFromSerializedObject(aSerializedObject: TSerializedObject);
  protected
    procedure DefineSerializer(aSerializer: TSerializer); virtual; abstract;
    function VindClass(aClassName: String): TClass; virtual;
  public
    function ToSerializedString: String;
    procedure LoadFromSerializedString(aValue: String);
  end;


  TSerializedItem = class(TObject)
  public
    Naam: String;
    constructor Create(aNaam: String);
    procedure Load(aContainer: TSerializedObjectContainer); virtual; abstract;
    procedure Store(aContainer: TSerializedObjectContainer); virtual; abstract;
  end;

  TSerializedByteItem = class(TSerializedItem)
  private
    FByteRef: PByte;
  public
    constructor Create(aNaam: String; aByteRef: PByte);
    procedure Load(aContainer: TSerializedObjectContainer); override;
    procedure Store(aContainer: TSerializedObjectContainer); override;
  end;

  TSerializedBooleanItem = class(TSerializedItem)
  private
    FBooleanRef: PBoolean;
  public
    constructor Create(aNaam: String; aBooleanRef: PBoolean);
    procedure Load(aContainer: TSerializedObjectContainer); override;
    procedure Store(aContainer: TSerializedObjectContainer); override;
  end;

  TSerializedIntegerItem = class(TSerializedItem)
  private
    FIntegerRef: PInteger;
  public
    constructor Create(aNaam: String; aIntegerRef: PInteger);
    procedure Load(aContainer: TSerializedObjectContainer); override;
    procedure Store(aContainer: TSerializedObjectContainer); override;
  end;

  TSerializedDoubleItem = class(TSerializedItem)
  private
    FDoubleRef: PDouble;
  public
    constructor Create(aNaam: String; aDoubleRef: PDouble);
    procedure Load(aContainer: TSerializedObjectContainer); override;
    procedure Store(aContainer: TSerializedObjectContainer); override;
  end;

  TSerializedStringItem = class(TSerializedItem)
  private
    FStringRef: MyPString;
  public
    constructor Create(aNaam: String; aStringRef: MyPString);
    procedure Load(aContainer: TSerializedObjectContainer); override;
    procedure Store(aContainer: TSerializedObjectContainer); override;
  end;

  TSerializedObjectItem = class(TSerializedItem)
  private
    FObjectRef: PMyPersistent;
    FClass: TMyPersistentClass;
  public
    constructor Create(aNaam: String; aObjectRef: PMyPersistent; aClass: TMyPersistentClass);
    procedure Load(aContainer: TSerializedObjectContainer); override;
    procedure Store(aContainer: TSerializedObjectContainer); override;
  end;

  TSerializedObjectListItem<A: class, constructor> = class(TSerializedItem)
  private
    FObjectListRef: PObject;
    FSerializer: TSerializer;
  public
    constructor Create(aNaam: String; aObjectListRef: PObject; aSerializer: TSerializer);
    procedure Load(aContainer: TSerializedObjectContainer); override;
    procedure Store(aContainer: TSerializedObjectContainer); override;
  end;

  TSerializer = class(TObject)
  private
    FMyPersistent: TMyPersistent;
    FItems: TObjectList<TSerializedItem>;
    function FindSerializedItem(aNaam: String): TSerializedItem;
  public
    WriteClassName: Boolean;
    constructor Create(aMyPersistent: TMyPersistent);
    destructor Destroy; override;
    procedure LoadFromSerializedObject(aSerializedObject: TSerializedObject);
    function GetSerializedObject: TSerializedObject;
    procedure AddInteger(aNaam: String; aIntegerRef: PInteger);
    procedure AddByte(aNaam: String; aByteRef: PByte);
    procedure AddBoolean(aNaam: String; aBooleanRef: PBoolean);
    procedure AddDouble(aNaam: String; aDoubleRef: PDouble);
    procedure AddString(aNaam: String; aStringRef: MyPString);
    procedure AddObject(aNaam: String; aObjectRef: PMyPersistent; aClass: TMyPersistentClass);
    procedure AddObjectList<A: class, constructor>(aNaam: String; aObjectListRef: PObject);
    function nmClass: String;
  end;

implementation

{ TSerializer }
constructor TSerializer.Create(aMyPersistent: TMyPersistent);
begin
  inherited Create;
  FMyPersistent := aMyPersistent;
  FItems := TObjectList<TSerializedItem>.Create;
end;

destructor TSerializer.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TSerializer.LoadFromSerializedObject(aSerializedObject: TSerializedObject);
var
  I: Integer;
  myContainer: TSerializedObjectContainer;
  mySerializedItem: TSerializedItem;
begin
  myContainer := TSerializedObjectContainer.Create(aSerializedObject);
  try
    for I := 0 to myContainer.Count-1 do
    begin
      mySerializedItem := FindSerializedItem(myContainer.Names[I]);
      if Assigned(mySerializedItem) then
        mySerializedItem.Load(myContainer);
    end;
  finally
    myContainer.Free;
  end;
end;

function TSerializer.GetSerializedObject: TSerializedObject;
var
  myContainer: TSerializedObjectContainer;
  mySerializedItem: TSerializedItem;
  I: Integer;
begin
  Result := TSerializedObject.Create;
  try
    myContainer := TSerializedObjectContainer.Create(Result);
    try
      for I := 0 to FItems.Count-1 do
      begin
        mySerializedItem := FItems[I];
        mySerializedItem.Store(myContainer);
      end;
    finally
      myContainer.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TSerializer.AddInteger(aNaam: String; aIntegerRef: PInteger);
begin
  FItems.Add(TSerializedIntegerItem.Create(aNaam, aIntegerRef));
end;

procedure TSerializer.AddByte(aNaam: String; aByteRef: PByte);
begin
  FItems.Add(TSerializedByteItem.Create(aNaam, aByteRef));
end;

procedure TSerializer.AddBoolean(aNaam: String; aBooleanRef: PBoolean);
begin
  FItems.Add(TSerializedBooleanItem.Create(aNaam, aBooleanRef));
end;

procedure TSerializer.AddDouble(aNaam: String; aDoubleRef: PDouble);
begin
  FItems.Add(TSerializedDoubleItem.Create(aNaam, aDoubleRef));
end;

procedure TSerializer.AddString(aNaam: String; aStringRef: MyPString);
begin
  FItems.Add(TSerializedStringItem.Create(aNaam, aStringRef));
end;

procedure TSerializer.AddObject(aNaam: String; aObjectRef: PMyPersistent; aClass: TMyPersistentClass);
begin
  FItems.Add(TSerializedObjectItem.Create(aNaam, aObjectRef, aClass));
end;

procedure TSerializer.AddObjectList<A>(aNaam: String; aObjectlistRef: PObject);
begin
  FItems.Add(TSerializedObjectListItem<A>.Create(aNaam, aObjectListRef, Self));
end;

function TSerializer.FindSerializedItem(aNaam: String): TSerializedItem;
var
  mySerializedItem: TSerializedItem;
begin
  Result := nil;
  for mySerializedItem in FItems do
    if mySerializedItem.Naam = aNaam then
      Result := mySerializedItem;
end;

function TSerializer.nmClass: String;
begin
  Result := 'Class';
end;

{ TSerializedItem }
constructor TSerializedItem.Create(aNaam: String);
begin
  inherited Create;
  Naam := aNaam;
end;

{ TSerializedIntegerItem }
constructor TSerializedIntegerItem.Create(aNaam: String; aIntegerRef: PInteger);
begin
  inherited Create(aNaam);
  FIntegerRef := aIntegerRef;
end;

procedure TSerializedIntegerItem.Load(aContainer: TSerializedObjectContainer);
begin
  FIntegerRef^ := aContainer.Integers[Naam];
end;

procedure TSerializedIntegerItem.Store(aContainer: TSerializedObjectContainer);
begin
  aContainer.Add(Naam, FIntegerRef^);
end;

{ TSerializedByteItem }
constructor TSerializedByteItem.Create(aNaam: String; aByteRef: PByte);
begin
  inherited Create(aNaam);
  FByteRef := aByteRef;
end;

procedure TSerializedByteItem.Load(aContainer: TSerializedObjectContainer);
begin
  FByteRef^ := aContainer.Integers[Naam];
end;

procedure TSerializedByteItem.Store(aContainer: TSerializedObjectContainer);
begin
  aContainer.Add(Naam, FByteRef^);
end;

{ TSerializedBooleanItem }
constructor TSerializedBooleanItem.Create(aNaam: String; aBooleanRef: PBoolean);
begin
  inherited Create(aNaam);
  FBooleanRef := aBooleanRef;
end;

procedure TSerializedBooleanItem.Load(aContainer: TSerializedObjectContainer);
begin
  FBooleanRef^ := aContainer.Booleans[Naam];
end;

procedure TSerializedBooleanItem.Store(aContainer: TSerializedObjectContainer);
begin
  aContainer.Add(Naam, FBooleanRef^);
end;

{ TSerializedDoubleItem }
constructor TSerializedDoubleItem.Create(aNaam: String; aDoubleRef: PDouble);
begin
  inherited Create(aNaam);
  FDoubleRef := aDoubleRef;
end;

procedure TSerializedDoubleItem.Load(aContainer: TSerializedObjectContainer);
begin
  FDoubleRef^ := aContainer.Floats[Naam];
end;

procedure TSerializedDoubleItem.Store(aContainer: TSerializedObjectContainer);
begin
  aContainer.Add(Naam, FDoubleRef^);
end;

{ TSerializedStringItem }
constructor TSerializedStringItem.Create(aNaam: String; aStringRef: MyPString);
begin
  inherited Create(aNaam);
  FStringRef := aStringRef;
end;

procedure TSerializedStringItem.Load(aContainer: TSerializedObjectContainer);
begin
  FStringRef^ := aContainer.Strings[Naam];
end;

procedure TSerializedStringItem.Store(aContainer: TSerializedObjectContainer);
begin
  aContainer.Add(Naam, FStringRef^);
end;

{ TSerializedObjectItem }
constructor TSerializedObjectItem.Create(aNaam: String; aObjectRef: PMyPersistent; aClass: TMyPersistentClass);
begin
  inherited Create(aNaam);
  FObjectRef := aObjectRef;
  FClass := aClass;
end;

procedure TSerializedObjectItem.Load(aContainer: TSerializedObjectContainer);
var
  myPersistent: TMyPersistent;
begin
  myPersistent := FClass.Create;
  myPersistent.PLoadFromSerializedObject(aContainer.Objects[Naam]);
  FObjectRef^ := myPersistent;
end;

procedure TSerializedObjectItem.Store(aContainer: TSerializedObjectContainer);
var
  myPersistent: TMyPersistent;
begin
  myPersistent := FObjectRef^;
  if Assigned(myPersistent) then
    aContainer.Add(Naam, myPersistent.PGetSerializedObject);
end;

{ TSerializedObjectListItem }
constructor TSerializedObjectListItem<A>.Create(aNaam: String; aObjectListRef: PObject; aSerializer: TSerializer);
begin
  inherited Create(aNaam);
  FObjectListRef := aObjectListRef;
  FSerializer := aSerializer;
end;

procedure TSerializedObjectListItem<A>.Load(aContainer: TSerializedObjectContainer);
var
  myItem: A;
  myList: TObjectList<A>;
  mySerializedArray: TSerializedArray;
  mySerializedObject: TSerializedObject;
  myArrayItem: TSerializedValue;
  myClassValue: TSerializedValue;
  myClass: TClass;
  I: Integer;
begin
  myList := TObjectList<A>.Create;
  FObjectListRef^ := myList;
  mySerializedArray := aContainer.Arrays[Naam];
  for I := 0 to mySerializedArray.Count-1 do
  begin
    myArrayItem := mySerializedArray[I];
    mySerializedObject := myArrayItem as TSerializedObject;
    myClassValue := mySerializedObject.Find(FSerializer.nmClass);
    if Assigned(myClassValue) then
    begin
      myClass := FSerializer.FMyPersistent.VindClass(myClassValue.Value);
      if Assigned(myClass) then
        myItem := myClass.Create as A
      else
        myItem := nil;
    end
    else
      myItem := A.Create;
    if Assigned(myItem) then
    begin
      myList.Add(myItem);
      (myItem as TMyPersistent).PLoadFromSerializedObject(mySerializedObject);
    end;
  end;
end;

procedure TSerializedObjectListItem<A>.Store(aContainer: TSerializedObjectContainer);
var
  myList: TObjectList<A>;
  myArray: TSerializedArray;
  myPersistent: TMyPersistent;
  myObject: TObject;
  I: Integer;
begin
  myList := (FObjectListRef^ as TObjectList<A>);
  myArray := TSerializedArray.Create;
  for I := 0 to myList.Count-1 do
  begin
    myObject := myList[I];
    myPersistent := myObject as TMyPersistent;
    myArray.Add(myPersistent.PGetSerializedObject);
  end;
  aContainer.Add(Naam, myArray);
end;

{ TMyPersistent }
procedure TMyPersistent.PLoadFromSerializedObject(aSerializedObject: TSerializedObject);
var
  mySerializer: TSerializer;
begin
  mySerializer := TSerializer.Create(Self);
  try
    DefineSerializer(mySerializer);
    mySerializer.LoadFromSerializedObject(aSerializedObject);
  finally
    mySerializer.Free;
  end;
end;

function TMyPersistent.VindClass(aClassName: String): TClass;
begin
  Result := nil;
end;

function TMyPersistent.PGetSerializedObject: TSerializedObject;
var
  mySerializer: TSerializer;
begin
  mySerializer := TSerializer.Create(Self);
  try
    DefineSerializer(mySerializer);
    FClassName := ClassName;
    if mySerializer.WriteClassName then
      mySerializer.AddString(mySerializer.nmClass, @FClassName);
    Result := mySerializer.GetSerializedObject;
  finally
    mySerializer.Free;
  end;
end;

function TMyPersistent.ToSerializedString: String;
var
  myContainer: TSerializedObjectContainer;
  mySerializedObject: TSerializedObject;
begin
  mySerializedObject := PGetSerializedObject;
  try
    myContainer := TSerializedObjectContainer.Create(mySerializedObject);
    try
      Result := myContainer.AsString;
    finally
      myContainer.Free;
    end;
  finally
    mySerializedObject.Free;
  end;
end;

procedure TMyPersistent.LoadFromSerializedString(aValue: String);
var
  myContainer: TSerializedObjectContainer;
begin
  myContainer := StringNaarSerializedObject(aValue);
  try
    PLoadFromSerializedObject(myContainer.SerializedObject);
  finally
    myContainer.Free;
  end;
end;

end.

