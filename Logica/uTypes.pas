unit uTypes;


interface

uses
  Types,
  Classes, SysUtils;

type
  DWord = Types.DWord;
  DWord_PTR = NativeUInt;
  TMoment = DWord; // wordt gebruik in TToon
  TDeltaMoment = LongInt;
  TTijd   = DWord; // in milliseconden

  TMyCursor = (mycrDefault, mycrSizeWE, mycrSizeAll);
  TKleur = (klRood, klBlauw, klGroen, klZwart, klLichtBlauw);

  UINT = LongWord;

implementation

end.

