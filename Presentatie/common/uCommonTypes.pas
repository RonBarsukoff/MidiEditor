unit uCommonTypes;

interface

type
  TAfspeelToon = record
    Kanaal, Hoogte, Velocity, Lengte: Integer; Aan: Boolean;
  end;
  TGetToonEvent = function(var aAfspeelToon: TAfspeelToon): Boolean of Object;
  TAskStopToonEvent = function: Boolean of Object;
  TUpdateStatusEvent = procedure(aOk: Boolean; const aMelding: String) of Object;
  TToonInEvent = procedure(aToon: TAfspeelToon) of Object;

implementation

end.
