unit uLog;

interface
{$ifndef fpc}
uses
  CodeSiteLogging;
{$endif}

procedure Log(const aMessage: String);

implementation

procedure Log(const aMessage: String);
begin
  {$ifndef fpc}
  CodeSite.Send(csmLevel2, aMessage);
  {$endif}
end;

end.
