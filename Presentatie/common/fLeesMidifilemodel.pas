unit fLeesMidifileModel;

interface

uses
  Classes, SysUtils,
  { MidiEditor }
  cmpMidiObject,
  cmpTonenObject;

type
  TLeesMidifileModel = class(TObject)
  private
    FMidiObject: TMidiObject;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Lees(aFileName: String);
    procedure VulTonenObject(aTonenObject: TTonenObject);
    procedure LeesMidiEvents(aNootEvents, aOverigeEvents: TStrings; aTrackNr, aKanaalNr: Integer);
    procedure VulKanalen(aKanalen: TStrings; aTrackIndex: Integer);
    procedure VulTekstenControl(aTeksten: TStrings; aTrackIndex: Integer);
    procedure VulTrackControl(aTracks: TStrings);
    property MidiObject: TMidiObject read FMidiObject;
  end;


implementation
uses
  uMidiConstants,
  cmpMidiLezer,
  cmpMidiObjectNaarTonenObjectConverter,
  cmpMidiEvent;

constructor TLeesMidifileModel.Create;
begin
  inherited Create;
  FMidiObject := TMidiObject.Create;
end;

destructor TLeesMidifileModel.Destroy;
begin
  FMidiObject.Free;
  inherited Destroy;
end;

procedure TLeesMidifileModel.Lees(aFileName: String);
var
  myLezer: TMidiLezer;
begin
  myLezer := TMidiLezer.Create(FMidiObject);
  try
    myLezer.Lees(aFileName);
  finally
    myLezer.Free;
  end;
end;

procedure TLeesMidifileModel.VulTonenObject(aTonenObject: TTonenObject);
var
  myMidiConverter: TMidiConverter;
begin
  myMidiConverter := TMidiConverter.Create;
  try
    aTonenObject.CreateObjecten;
    myMidiConverter.MidiNaarTonen(FMidiObject, aTonenObject);
    aTonenObject.Init;
  finally
    myMidiConverter.Free;
  end;
end;

procedure TLeesMidifileModel.LeesMidiEvents(aNootEvents, aOverigeEvents: TStrings; aTrackNr, aKanaalNr: Integer);
var
  myTrack: TMidiTrack;
  myKanaal: TMidiKanaal;
  I: Integer;
  myEvent: TMidiEvent;
begin
  aNootEvents.Clear;
  aOverigeEvents.Clear;
  if (aTrackNr >= 0)
  and (aTrackNr <= FMidiObject.Tracks.Count- 1)
  and (aKanaalNr >= 1)
  and (aKanaalNr <= midiMaxKanalen) then
  begin
    myTrack := FMidiObject.Tracks[aTrackNr];
    myKanaal := myTrack.Kanaal[aKanaalNr];
    aNootEvents.BeginUpdate;
    try
      for I := 0 to myKanaal.NootEvents.Count -1 do
      begin
        myEvent := myKanaal.NootEvents[I];
        aNootEvents.Add(myEvent.Tekst);
      end;
    finally
      aNootEvents.EndUpdate;
    end;
    aOverigeEvents.BeginUpdate;
    try
    for I := 0 to myKanaal.MidiOpdrachten.Count -1 do
    begin
      myEvent := myKanaal.MidiOpdrachten[I];
      aOverigeEvents.Add(myEvent.Tekst);
    end;
    finally
      aOverigeEvents.EndUpdate;
    end;
  end;
end;

procedure TLeesMidifileModel.VulKanalen(aKanalen: TStrings; aTrackIndex: Integer);
var
  myTrack: TMidiTrack;
  I: Integer;
begin
  aKanalen.Clear;
  if (aTrackIndex>=0) and (aTrackIndex<=FMidiObject.Tracks.Count- 1) then
  begin
    myTrack := FMidiObject.Tracks[aTrackIndex];
    for I := 1 to midiMaxKanalen do
      aKanalen.Add(IntToStr(myTrack.Kanaal[I].NootEvents.Count));
  end;
end;

procedure TLeesMidifileModel.VulTekstenControl(aTeksten: TStrings; aTrackIndex: Integer);
var
  myTrack: TMidiTrack;
  I: integer;
  myTekst: TTekstEvent;
begin
  aTeksten.Clear;
  if (aTrackIndex >= 0)
  and (aTrackIndex <= FMidiObject.Tracks.Count-1) then
  begin
    myTrack := FMidiObject.Tracks[aTrackIndex];
    for I := 0 to myTrack.Teksten.Count-1 do
    begin
      myTekst := myTrack.Teksten[I];
      aTeksten.Add(myTekst.Tekst);
    end;
  end;
end;

procedure TLeesMidifileModel.VulTrackControl(aTracks: TStrings);
var
  I: Integer;
  myTrack: TMidiTrack;
begin
  aTracks.Clear;
  for I := 0 to FMidiObject.Tracks.Count-1 do
  begin
    myTrack := FMidiObject.Tracks[I];
    aTracks.Add(myTrack.Naam);
  end;
end;

end.

