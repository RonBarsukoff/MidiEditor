unit uLinuxMidiInspeelThread;

interface

uses
  Classes, SysUtils,

  asoundlib,
  uCommonTypes;

type
  TLinuxMidiInspeelThread = class(TThread)
  private
    FAfspeelToon: TAfspeelToon;
    procedure handleToonEvent;
  protected
    procedure Execute; override;
  public
    SeqHandle: Psnd_seq_t;
    OnToonEvent: TToonInEvent;
  end;

implementation

procedure TLinuxMidiInspeelThread.Execute;
var
  r: integer;
  ev: psnd_seq_event_t;
  myType: snd_seq_event_type;
begin
  while not Terminated do
  begin
    r:= snd_seq_event_input(SeqHandle, @ev );
    while ( r > 0 ) do
    begin
      myType := snd_seq_event_type(ev.type_);
      if myType in [SND_SEQ_EVENT_NOTE, SND_SEQ_EVENT_NOTEON, SND_SEQ_EVENT_NOTEOFF, SND_SEQ_EVENT_KEYPRESS] then
      begin
        FAfspeelToon.Aan := ev^.data.note.velocity <> 0;
        FAfspeelToon.Hoogte:= ev^.data.note.note;
        FAfspeelToon.Velocity:= ev^.data.note.velocity;
        FAfspeelToon.Kanaal:= ev^.data.note.channel;
        FAfspeelToon.Lengte:= 1;
        Synchronize(handleToonEvent);
      end;
      r:= snd_seq_event_input(SeqHandle, @ev );
    end;
    Sleep(1);
  end;
end;

procedure TLinuxMidiInspeelThread.handleToonEvent;
begin
  if Assigned(OnToonEvent) then
    OnToonEvent(FAfspeelToon);
end;

end.

