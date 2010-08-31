program jc;

{*
Experimental Javascript Calculator for command line
}

{$ifdef FPC}
{$mode DELPHI}
{$else}
{$apptype CONSOLE}
{$endif}

uses
  SysUtils, Classes, fpcjs;

var
  JSRuntime: TFpcJsRuntime;
  JSScript: TFpcJsScript;
  cmd : string;
  parsed : boolean;

begin
  JSRuntime := TFpcJsRunTime.Create();
  JSScript := JSRuntime.CreateScript();
  // include main library jc.js
  if FileExists('jc.js') then
    if not JSScript.EvaluateFile('jc.js') then
      writeln('error: cannot evaluate implicit library "jc.js"');
  // main loop
  repeat
    readln(cmd);
    cmd := trim(cmd);
    // ignore empty lines
    if cmd='' then
      continue;
    // function declaration cannot be don via echo
    if pos('function ',cmd) = 1 then
    begin
      parsed := JSScript.Evaluate(cmd);
      if not parsed then
        writeln('error: cannot evaluate script')
      else
        writeln('[function]');
      continue;
    end;
    // everything else pass through echo
    parsed := JSScript.Evaluate('echo(indent,'+cmd+',suffix);');
    if not parsed then
      writeln('error: cannot evaluate script');
  until (cmd='q')or(cmd='quit')or(cmd='exit');
end.
