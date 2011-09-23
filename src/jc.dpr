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
  cmd, jclib : string;
  parsed : boolean;

begin
  JSRuntime := TFpcJsRunTime.Create();
  JSScript := JSRuntime.CreateScript();
  // include main library jc.js
  jclib := GetEnvironmentVariable('FPCJS_PATH')+'jc.js';
  if not FileExists(jclib) then
    writeln('error: cannot locate main jc library "'+jclib+'"'); 
  if FileExists(jclib) then
    if not JSScript.EvaluateFile(jclib) then
      writeln('error: cannot evaluate implicit library "'+jclib+'"');
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
    // if it cannot be parsed throught echo, run it as is
    if not parsed then
      parsed := JSScript.Evaluate(cmd);
    if not parsed then 
      writeln('error: cannot evaluate script');
  until (cmd='q')or(cmd='quit')or(cmd='exit');
end.
