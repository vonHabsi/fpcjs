program test6;

{*
Test6 - issue #3

USING FPC on windows:

  a in script = 10
  b in script = -10
  
  a in pascal = 10
  b in pascal = -10
  a in pascal = 10 (AsInteger)
  b in pascal = -10 (AsInteger)
  integer(a) in pascal = 10 (AsInteger)
  integer(b) in pascal = -10 (AsInteger)
  a in pascal = 10.0000000000 (AsDouble)
  b in pascal = -10.0000000000 (AsDouble)

USING DELPHI 7 on windows 7 64 bit:

  a in script = 10
  b in script = -2147483638
  
  a in pascal = 10
  b in pascal = -2147483638
  a in pascal = 10 (AsInteger)
  b in pascal = -2147483638 (AsInteger)
  integer(a) in pascal = 10 (AsInteger)
  integer(b) in pascal = -2147483638 (AsInteger)
  a in pascal = 10.0000000000 (AsDouble)
  b in pascal = -10.0000000000 (AsDouble)

}

{$ifdef FPC}
{$mode DELPHI}
{$else}
{$apptype CONSOLE}
{$endif}

uses
  SysUtils, Classes, fpcjs, js15decl;

var
  JSRuntime: TFpcJsRuntime;
  JSScript: TFpcJsScript;
  parsed: boolean;

begin
  JSRuntime := TFpcJsRunTime.Create();
  JSScript := JSRuntime.CreateScript();

  // evaluate script
  parsed := JSScript.Evaluate('var a; var b; a=10; b=a*(-1); echo("a in script = ",a,"\n"); echo("b in script = ",b,"\n\n");');
  if not parsed then
    writeln('Error #1 - evaluation failed'); 

  writeln('a in pascal = ',JSScript.GetValue('a'));
  writeln('b in pascal = ',JSScript.GetValue('b'));

  writeln('a in pascal = ',JSScript.GetValueAsInteger('a'),' (AsInteger)');
  writeln('b in pascal = ',JSScript.GetValueAsInteger('b'),' (AsInteger)');

  writeln('integer(a) in pascal = ',integer(JSScript.GetValueAsInteger('a')),' (AsInteger)');
  writeln('integer(b) in pascal = ',integer(JSScript.GetValueAsInteger('b')),' (AsInteger)');

  writeln('a in pascal = ',JSScript.GetValueAsDouble('a'):1:10,' (AsDouble)');
  writeln('b in pascal = ',JSScript.GetValueAsDouble('b'):1:10,' (AsDouble)');

  writeln('Press enter to exit');
  readln;  
end.