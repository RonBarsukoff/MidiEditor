unit frStemControls;

{xxx$mode objfpc}{xxx$H+}

interface

uses
  SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls;

type
  TframeStemControls = class(TFrame)
    lNaam: TLabel;
    cbZichtbaar: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.lfm}

end.
