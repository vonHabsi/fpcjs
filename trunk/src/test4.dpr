program test4;

{*
Test4 - reported by vpsiteworks in issue 2
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
  sum : Variant;
  parsed : boolean;

procedure show;
begin
  JSRuntime := TFpcJsRunTime.Create();
  JSScript := JSRuntime.CreateScript();
  parsed := JSScript.Evaluate('function fact(n) { if (n <= 1) return 1; return n * fact(n-1); }');
  if not parsed then
    raise Exception.Create('Error during evaluation of script');
  //parsed := JSScript.EvaluateFile('test.js');
  sum := JSScript.Call('fact', [5]);
  writeln('sum = ',sum);

  // setsess('foo', 'bar');
  // JSScript.SetValue('n',123);
  // outln('n=' + String(JSScript.GetValue('n')));
  // outln('<br />fact=' + String(JSScript.Call('fact', [5])));
end;

begin
  Show;
  writeln('Press enter to exit');
  readln;  
end.