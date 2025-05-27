unit uMidiConstants;

interface

const
  midictrl_volume       = $07;
  midictrl_pan          = $0A;
  midictrl_damper_pedal = $40;
  midictrl_portamento	= $41;
  midictrl_sostenuto	= $42;
  midictrl_soft_pedal	= $43;
  midictrl_effect1	= 91; // reverb
  midictrl_effect2	= 92; // tremolo
  midictrl_effect3	= 93; // chorus
  midictrl_effect4	= 94; // detune
  midictrl_effect5	= 95; // phaser

  note_off         	= $80;
  note_on          	= $90;
  poly_aftertouch  	= $a0;
  control_change        = $b0;
  program_chng     	= $c0;
  channel_aftertouch    = $d0;
  pitch_wheel      	= $e0;
  system_exclusive      = $f0;
  delay_packet	        = $0F;

const
(* 7 bit controllers *)
  general_4             = $44;
  hold_2		= $45;
  general_5	        = $50;
  general_6	        = $51;
  general_7	        = $52;
  general_8	        = $53;
  tremolo_depth	        = $5c;
  chorus_depth	        = $5d;
  detune		= $5e;
  phaser_depth	        = $5f;

(* parameter values *)
  data_inc	        = $60;
  data_dec	        = $61;

(* parameter selection *)
  non_reg_lsb	        = $62;
  non_reg_msb	        = $63;
  reg_lsb		= $64;
  reg_msb		= $65;

(* Standard MIDI Files meta event definitions *)
  meta_event		= $FF;
  sequence_number 	= $00;
  text_event	    	= $01;
  copyright_notice 	= $02;
  sequence_name    	= $03;
  instrument_name 	= $04;
  lyric	        	= $05;
  marker	       	= $06;
  cue_point		= $07;
  channel_prefix	= $20;
  end_of_track	   	= $2f;
  set_tempo     	= $51;
  smpte_offset	  	= $54;
  time_signature	= $58;
  key_signature		= $59;
  sequencer_specific    = $74;

(* Manufacturer's ID number *)
  Seq_Circuits = $01; (* Sequential Circuits Inc. *)
  Big_Briar    = $02; (* Big Briar Inc.           *)
  Octave       = $03; (* Octave/Plateau           *)
  Moog         = $04; (* Moog Music               *)
  Passport     = $05; (* Passport Designs         *)
  Lexicon      = $06; (* Lexicon 			*)
  Tempi        = $20; (* Bon Tempi                *)
  Siel         = $21; (* S.I.E.L.                 *)
  Kawai        = $41;
  Roland       = $42;
  Korg         = $42;
  Yamaha       = $43;

(* miscellaneous definitions *)
//  MThd: LongInt = $4d546864;
//  MTrk: LongInt = $4d54726b;
  MThd = 'MThd';
  MTrk = 'MTrk';

(* midifile dll return codes *)
  { 1 - 100: Dos kodes }
  mfNoError          = 0;
  mfErrInvalidHandle = 201;
  mfOutOfHandles     = 202;

//  midiCentraleC = 60;
  midiLaagsteToon = 21; // A0
  midiHoogsteToon = 127; // G9
  midiMaxKanalen = 16;

  MidiInstrumentNaam: array[0..127] of String = (
    'Vleugel',
    'Piano',
    'Piano elektrisch',
    'Honky tonk',
    'Elektrische piano 1',
    'Elektrische piano 2',
    'Harpsichord',
    'Klavecimbel',
    'Celesta',
    'Klokkenspel',
    'Music box',
    'Vibrafoon',
    'Marimba',
    'Xylofoon'
    , 'Tubular bells'
    , 'Dulcimer'
    , 'Draagbaar orgel'
    , 'Percussie orgel'
    , 'Rock orgel'
    , 'Kerk orgel'
    , 'Reed orgel'
    , 'Akkordeon'
    , 'Harmonika'
    , 'Tango akkordeon'
    , 'Akoestische gitaar ( nylon snaren )'
    , 'Akoestische gitaar ( stalen snaren )'
    , 'Elektrische gitaar ( jazz )'
    , 'Elektrische gitaar ( clean )'
    , 'Elektrische gitaar ( muted )'
    , 'Overdrive gitaar'
    , 'Vervormde gitaar'
    , 'Gitaar flageoletten'
    , 'Akoestische bas'
    , 'Elektrische bas ( finger )'
    , 'Elektrische bas ( pick )'
    , 'Fretloze bas'
    , 'Slap bass 1'
    , 'Slap bass 2'
    , 'Synthesizer bas 1'
    , 'Synthesizer bas 2'
    , 'Viool'
    , 'Altviool'
    , 'Cello'
    , 'Contrabas'
    , 'Violen tremolo '
    , 'Violen pizzicato'
    , 'Harp'
    , 'Pauken'
    , 'Viool ensemble 1'
    , 'Viool ensemble 2'
    , 'Synth. strings 1'
    , 'Synth. strings 2'
    , 'Koor aaahh'
    , 'Stem ooohh'
    , 'Synth. stem'
    , 'Orchestra hit'
    , 'Trompet'
    , 'Trombone'
    , 'Tuba'
    , 'Trompet (gedempt)'
    , 'Hoorn'
    , 'Brass section'
    , 'Synth. koper 1'
    , 'Synth. koper 2'
    , 'Sopraan sax'
    , 'Alt sax'
    , 'Tenor sax'
    , 'Bariton sax'
    , 'Hobo'
    , 'Engelse hoorn'
    , 'Fagot'
    , 'Klarinet'
    , 'Piccolo'
    , 'Dwarsfluit'
    , 'Blokfluit'
    , 'Pan fluit'
    , 'Blown bottle'
    , 'Skakuhachi'
    , 'Fluit (met de lippen)'
    , 'Ocarina'
    , 'Lead 1 ( square )'
    , 'Lead 2 (zaagtand)'
    , 'Lead 3 (valliope)'
    , 'Lead 4 (chiff)'
    , 'Lead 5 (charang)'
    , 'Lead 6 (voice)'
    , 'Lead 7 (fifths)'
    , 'Lead 8 (bass+lead)'
    , 'Pad 1 (new age)'
    , 'Pad 2 (warm)'
    , 'Pad 3 (polysynthesizer)'
    , 'Pad 4 (koor)'
    , 'Pad 5 (bowed)'
    , 'Pad 6 (metalic)'
    , 'Pad 7 (halo)'
    , 'Pad 8 (sweep)'
    , 'FX 1 (regen)'
    , 'FX 2 (soudtrack)'
    , 'FX 3 (kristal)'
    , 'FX 4 (atmosfeer)'
    , 'FX 5 (helder)'
    , 'FX 6 (goblines)'
    , 'FX 7 (echos)'
    , 'FX 8 (sci-fi)'
    , 'Sitar'
    , 'Banjo'
    , 'Shamisen'
    , 'Koto'
    , 'Kalimba'
    , 'Doedelzak'
    , 'Fiddle'
    , 'Shanai'
    , 'Tinkle bell'
    , 'Agogo'
    , 'Steel drums'
    , 'Woodblock'
    , 'Taiko drum'
    , 'Melodic tom'
    , 'Synth. drum'
    , 'Reverse cymbal'
    , 'Gitaar fretgeluiden'
    , 'Ademgeluiden'
    , 'Branding'
    , 'Vogelgefluit'
    , 'Telefoonrinkel'
    , 'Helikopter'
    , 'Applaus'
    , 'Geweerschot'
  );

function MidiStatusTekst(aStatus: Byte): String;
function MidiControlTekst(aControllerName, aData: Byte; aSeparator: String): String;
function ToonhoogteAlsTekst(aHoogte: Byte): String;
//function MMResultString(aMMResult: Integer): String;

implementation
uses
  SysUtils,
  uMMProcs;

function MidiStatusTekst(aStatus: Byte): String;
begin
  case aStatus of
    note_off:
      Result := 'note off';
    note_on:
      Result := 'note on';
    poly_aftertouch:
      Result := 'poly_aftertouch';
    control_change:
      Result := 'control_change';
    program_chng:
      Result := 'program change';
    channel_aftertouch:
      Result := 'after touch';
    pitch_wheel:
      Result := 'pitch wheel';
    system_exclusive:
      Result := 'system exclusive';
    delay_packet:
      Result := 'delay packte';
  end;

end;

function AanUit(aData: Byte): String;
begin
  if aData <= 63 then
    Result := 'Uit'
  else
    Result := 'Aan';
end;

function MidiControlTekst(aControllerName, aData: Byte; aSeparator: String): String;
begin
  case aControllerName of
    midictrl_volume:
      Result := 'Volume' + aSeparator + IntToStr(aData);
    midictrl_pan:
      Result := 'Panorama' + aSeparator + IntToStr(aData);
    midictrl_damper_pedal:
      Result := 'Pedaal' + aSeparator + AanUit(aData);
    midictrl_portamento:
      Result := 'Portamento' + aSeparator + AanUit(aData);
    midictrl_sostenuto:
      Result := 'Sostenuto' + aSeparator + AanUit(aData);
    midictrl_soft_pedal:
      Result := 'Studiepedaal' + aSeparator + AanUit(aData);
    midictrl_effect1: // reverb
      Result := 'Effect 1 (tremolo)' + aSeparator + IntToStr(aData);
(*    midictrl_effect2	= 92; // tremolo
    midictrl_effect3	= 93; // chorus
    midictrl_effect4	= 94; // detune
    midictrl_effect5	= 95; // phaser  *)
    else
      Result := IntToStr(aControllerName);
  end;
end;

function ToonhoogteAlsTekst(aHoogte: Byte): String;
var
  myOctaaf: Integer;
  myLetterIndex: Integer;
const
  myLetters: array[0..11] of String = (
    'A',
    'A#',
    'B',
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#'
  );

begin
  myOctaaf := (aHoogte-midiLaagsteToon) div 12;
  myLetterIndex := (aHoogte-midiLaagsteToon) mod 12;
  Result := myLetters[myLetterIndex]+IntToStr(myOctaaf);
end;

//function MMResultString(aMMResult: Integer): String;
//begin
//  case aMMResult of
//    MMSYSERR_NOERROR: Result := 'Ok';
//    MMSYSERR_ERROR: Result := 'unspecified error';
//    MMSYSERR_BADDEVICEID: Result := 'device ID out of range';
//    MMSYSERR_NOTENABLED: Result := 'driver failed enable';
//    MMSYSERR_ALLOCATED: Result := 'device already allocated';
//    MMSYSERR_INVALHANDLE: Result := 'device handle is invalid';
//    MMSYSERR_NODRIVER: Result := 'no device driver present';
//    MMSYSERR_NOMEM: Result := 'memory allocation error';
//    MMSYSERR_NOTSUPPORTED: Result := 'function is not supported';
//    MMSYSERR_BADERRNUM: Result := 'error value out of range';
//    MMSYSERR_INVALFLAG: Result := 'invalid flag passed';
//    MMSYSERR_INVALPARAM: Result := 'invalid parameter passed';
//    MMSYSERR_HANDLEBUSY: Result := 'handle being used simultaneously on another thread (eg callback)';
//    MMSYSERR_INVALIDALIAS: Result := 'specified alias not found';
//    MMSYSERR_BADDB: Result := 'bad registry database';
//    MMSYSERR_KEYNOTFOUND: Result := 'registry key not found';
//    MMSYSERR_READERROR: Result := 'registry read error';
//    MMSYSERR_WRITEERROR: Result := 'registry write error';
//    MMSYSERR_DELETEERROR: Result := 'registry delete error';
//    MMSYSERR_VALNOTFOUND: Result := 'registry value not found';
//    MMSYSERR_NODRIVERCB: Result := 'driver does not call DriverCallback';
//    MMSYSERR_BASE + 21 {MMSYSERR_MOREDATA niet beschikbaar in fpc}: Result := 'more data to be returned';
//  end;
//end;
//

end.
