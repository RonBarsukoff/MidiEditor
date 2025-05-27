unit cmpMidiObjectNaarTonenObjectConverter;

interface
uses
  Classes,
  SysUtils,
  cmpMidiObject,
  cmpMidiEvent,
  cmpToon,
  cmpTonenObject;

type
  TMidiConverter = class(TObject)
  private
    procedure EventsNaarTonen(aKanaalNr: Byte; aNootEvents: TKanaalEvents; aToonTrack: TToonTrack);
    procedure MidiEventsNaarToonEvents(aKanaalNr: Byte; aEvents: TDataEventList; aToonTrack: TToonTrack);
    procedure TonenNaarEvents(aTrack: TMidiTrack; aToonTrack: TToonTrack);
    procedure ToonEventsNaarMidiEvents(aTrack: TMidiTrack; aToonTrack: TToonTrack);
  public
    procedure MidiNaarTonen(aMidiObject: TMidiObject; aTonenObject: TTonenObject);
    procedure TonenNaarMidi(aMidiObject: TMidiObject; aTonenObject: TTonenObject);
  end;

implementation
uses
  uMidiConstants,
  cmpTrackElement,
  cmpPedaal,
  cmpVolumeChange,
  cmpPanoramaChange,
  cmpProgramChange,
  cmpTempoWisseling;

procedure TMidiConverter.MidiNaarTonen(aMidiObject: TMidiObject; aTonenObject: TTonenObject);
var
  I, J: Integer;
  myMidiTrack: TMidiTrack;
  myMidiKanaal: TMidiKanaal;
  myToonTrack: TToonTrack;
  myTempoChangeEvent: TTempoChangeEvent;
begin
  aTonenObject.Clear;
  aTonenObject.Division := aMidiObject.Division;
  for I := 0 to aMidiObject.TempoChanges.Count-1 do
  begin
    myTempoChangeEvent := (aMidiObject.TempoChanges[I] as TTempoChangeEvent);
    aTonenObject.TempoWisselingen.Add(TTempoWisseling.Create(aTonenObject, myTempoChangeEvent.Time, 1000000*60 div myTempoChangeEvent.Tempo));
  end;

  for I := 0 to aMidiObject.Tracks.Count-1 do
  begin
    myMidiTrack := aMidiObject.Tracks[I];
    myToonTrack := TToonTrack.Create(aTonenObject);
    myToonTrack.Naam := myMidiTrack.Naam;
    aTonenObject.Tracks.Add(myToonTrack);
    for J := 1 to midiMaxKanalen do
    begin
      myMidiKanaal := myMidiTrack.Kanaal[J];
      if myMidiKanaal.NootEvents.Count > 0 then
        EventsNaarTonen(J, myMidiKanaal.NootEvents, myToonTrack);
      if myMidiKanaal.MidiOpdrachten.Count > 0 then
        MidiEventsNaarToonEvents(J, myMidiKanaal.MidiOpdrachten, myToonTrack);
    end;
  end;
end;

procedure TMidiConverter.EventsNaarTonen(aKanaalNr: Byte; aNootEvents: TKanaalEvents; aToonTrack: TToonTrack);
var
  I, M: integer;
  myMidiEvent: TNootEvent;
  Tonen: array[0..255] of
    record
      NootAan: boolean;
      Moment: LongInt;
      Velocity: byte;
    end;
begin
  for I := 0 to 255 do
    Tonen[I].NootAan := false;
  for I := 0 to aNootEvents.Count-1 do
  begin
    myMidiEvent := aNootEvents[I] as TNootEvent;
    M := myMidiEvent.Time;
    if myMidiEvent.NoteOn then with Tonen[myMidiEvent.Hoogte] do
    begin
      if NootAan then { kan niet voorkomen. 28-11-3 blijkt toch wel voor te komen }
        //LogError('Fout in MidiNaarMuz. Noot is al aan')
      else
      begin
        NootAan := true;
        Moment := M;
        Velocity := myMidiEvent.Velocity;
      end
    end
    else { noot uit } with Tonen[myMidiEvent.Hoogte] do
    begin
      if not NootAan then { kan niet voorkomen. 28-11-3 blijkt toch wel voor te komen  }
        //LogError('Fout in MidiNaarMuz. Noot is al uit')
      else
      begin
        NootAan := false;
        aToonTrack.ToonLijst.Add(TToon.Create(aToonTrack, aKanaalNr, myMidiEvent.Hoogte, Velocity, Moment, M));
      end;
    end;
  end;
end;

procedure TMidiConverter.MidiEventsNaarToonEvents(aKanaalNr: Byte; aEvents: TDataEventList; aToonTrack: TToonTrack);
var
  I: Integer;
  myEvent: TDataEvent;
begin
  for I := 0 to aEvents.Count-1 do
  begin
    myEvent := aEvents[I];
    case myEvent.Status of
      control_change:
        case myEvent.Data1 of
          midictrl_damper_pedal:
            aToonTrack.DataElementen.Add(TPedaal.Create(aToonTrack, aKanaalNr, myEvent.Time, myEvent.Data2 >= 63));
          midictrl_volume:
            aToonTrack.DataElementen.Add(TVolumeChange.Create(aToonTrack, aKanaalNr, myEvent.Time, myEvent.Data2));
          midictrl_pan:
            aToonTrack.DataElementen.Add(TPanoramaChange.Create(aToonTrack, aKanaalNr, myEvent.Time, myEvent.Data2));
        end;
      program_chng:
        aToonTrack.DataElementen.Add(TProgramChange.Create(aToonTrack, aKanaalNr, myEvent.Time, myEvent.Data1));
    end;
  end;
end;

procedure TMidiConverter.TonenNaarMidi(aMidiObject: TMidiObject; aTonenObject: TTonenObject);
var
  I: Integer;
  myToonTrack: TToonTrack;
  myMidiTrack: TMidiTrack;
begin
  aMidiObject.Tracks.Clear;
  aMidiObject.Division := aTonenObject.Division;
  for I := 0 to aTonenObject.Tracks.Count-1 do
  begin
    myToonTrack := aTonenObject.Tracks[I];
    myMidiTrack := aMidiObject.NewTrack(myToonTrack.Naam);
    myMidiTrack.Naam := myToonTrack.Naam;
    TonenNaarEvents(myMidiTrack, myToonTrack);
    ToonEventsNaarMidiEvents(myMidiTrack, myToonTrack);
  end;
end;

procedure TMidiConverter.TonenNaarEvents(aTrack: TMidiTrack; aToonTrack: TToonTrack);
var
  myToon: TToon;
  myNootEvents: TKanaalEvents;
begin
  for myToon in aToonTrack.ToonLijst do
  begin
    myNootEvents := aTrack.Kanaal[myToon.KanaalNr].NootEvents;
    myNootEvents.Add(TNootEvent.Create(myToon.BeginMoment, 1, myToon.KanaalNr, myToon.Hoogte, myToon.Velocity, True));
    myNootEvents.Add(TNootEvent.Create(myToon.EindMoment, 1, myToon.KanaalNr, myToon.Hoogte, 0, False));
  end;
end;

procedure TMidiConverter.ToonEventsNaarMidiEvents(aTrack: TMidiTrack; aToonTrack: TToonTrack);
var
  myDataElement: TDataElement;
  myDataEvents: TDataEventList;
begin
  for myDataElement in aToonTrack.DataElementen do
  begin
    myDataEvents := aTrack.Kanaal[myDataElement.KanaalNr].MidiOpdrachten;
    case myDataElement.Soort of
      sdeVolume:
        myDataEvents.Add(TDataEvent.Create(myDataElement.BeginMoment, 1, myDataElement.KanaalNr, control_change, midictrl_volume, myDataElement.Data));
      sdePanorama:
        myDataEvents.Add(TDataEvent.Create(myDataElement.BeginMoment, 1, myDataElement.KanaalNr, control_change, midictrl_pan, myDataElement.Data));
      sdePedaal:
        myDataEvents.Add(TDataEvent.Create(myDataElement.BeginMoment, 1, myDataElement.KanaalNr, control_change, midictrl_damper_pedal, myDataElement.Data));
      sdeProgramChange:
        myDataEvents.Add(TDataEvent.Create(myDataElement.BeginMoment, 1, myDataElement.KanaalNr, program_chng, myDataElement.Data, 0));
    end;
  end;
end;

end.
