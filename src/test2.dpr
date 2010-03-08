program test2;

{*
Test2 - this should work on Delphi7 and in FPC too

- function echo - modified to work in delphi
- function echo - added printing of Void, Null, Object
- JS_InitStandardClasses coded in try/except to prevent some weird bug in recent (Firefox 3.6) dll
- Translated 1 error message to english in TFpcJsScript.Call
- modified fpc_global_callback to be compileable in dephi. It still don't work but at least you can compile it now, thus new warning in TFpcJsScript.RegisterFunction

}

{$ifdef FPC}
{$mode DELPHI}
{$else}
{$apptype CONSOLE}
{$endif}

uses
  FpcJs,
  js15decl in '..\libmozjs\js15decl.pas';

const
	source = 'var a = 6; var b = 7; echo("The ultimate answer is ",a*b,"\n");';

var r : TFpcJsRuntime;
    s : TFpcJsScript;
    
begin
  // create runtime
  r := TFpcJsRuntime.Create;

  // create script
  s := r.CreateScript;

  // evaluate script
  if not s.Evaluate(source) then
  	writeln('!!! EVALUATE ERROR !!!');
  
  // wait for user
  writeln('Press enter to exit');
  readln;

  // release variables
  r.Free;
end.
