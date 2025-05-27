unit uInstellingen;

interface
uses
  uTypes;

type
  TInstellingen = class(TObject)
  private
    FFilename: String;
  public
    MidiInDevice,
    MidiOutDevice: String;
    constructor Create;
    procedure BewaarMidiInstellingen;
    procedure LaadMidiInstellingen;
    function GetTrackKleur(aTrackIndex: Integer): TKleur;
  end;

const
  InstellingenFilename = '.\MidiEditor.ini';

implementation
uses
{$ifdef fpc}
 SysUtils,
{$else}
  System.IOUtils,
{$endif}
  Inifiles;

const
  sectionMidi = 'Midi';
  keyMidiIn   = 'MidiIn';
  keyMidiOut  = 'MidiOut';

constructor TInstellingen.Create;
begin
  inherited Create;
{$ifdef fpc}
  FFilename := ConcatPaths([GetUserDir, 'AppData', 'Roaming', 'MidiEditor', 'MidiEditor.ini']);
{$else}
  FFilename := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'MidiEditor'), 'MidiEditor.ini');
{$endif}
end;

procedure TInstellingen.BewaarMidiInstellingen;
var
  myInifile: TInifile;
begin
  myInifile := TInifile.Create(FFilename);
  try
    myInifile.WriteString(sectionMidi, keyMidiIn, MidiInDevice);
    myInifile.WriteString(sectionMidi, keyMidiOut, MidiOutDevice)
  finally
    myInifile.Free;
  end;
end;

procedure TInstellingen.LaadMidiInstellingen;
var
  myInifile: TInifile;
begin
  myInifile := TInifile.Create(FFilename);
  try
    MidiInDevice := myInifile.ReadString(sectionMidi, keyMidiIn, '');
    MidiOutDevice := myInifile.ReadString(sectionMidi, keyMidiOut, '')
  finally
    myInifile.Free;
  end;
end;

function TInstellingen.GetTrackKleur(aTrackIndex: Integer): TKleur;
begin
  aTrackIndex := (aTrackIndex) mod (ord(High(TKleur))+1);
  case aTrackIndex of
    0: Result := klRood;
    1: Result := klBlauw;
    2: Result := klGroen;
    3: Result := klZwart;
    4: Result := klLichtBlauw;
    else
      Result := klZwart;
  end;
end;

end.
