program jsh;

{*
Experimental JavaScript command line shell

Sample data file:

object QRLabel1: TQRLabel
  Left = 336
  Top = 264
end
object QRLabel2: TQRLabel
  Left = 336
  Top = 264
end
object QRLabel3: TQRLabel
  Left = 336
  Top = 264
end

Bash script:

cat zzz | grep object | sed 's/:/\n/;s/ /\n/' | grep qrl > zzz2
for i in `cat zzz2`; do echo "  $i.Caption := inttostr(a[][]);"; done

Desired output:

  QRLabel1.Caption := inttostr(a[][]);
  QRLabel2.Caption := inttostr(a[][]);
  QRLabel3.Caption := inttostr(a[][]);

JS Pseudocode

  cat zzz       - load file or url
  grep object
  ...  


}

{$ifdef FPC}
{$mode DELPHI}
{$else}
{$apptype CONSOLE}
{$endif}

uses
  SysUtils, Classes, Variants, fpcjs, js15decl;

var
  JSRuntime: TFpcJsRuntime;
  JSScript: TFpcJsScript;
  cmd : string;
  parsed : boolean;

function jsh_cat_file(cx: PJSContext; obj: PJSObject; argc: uintN; argv, rval: pjsval): JSBool; cdecl;
{*
Load multiple files into array, probably separated by EOL
}
var i : integer;
    params : TVariantArray;
    s : string;
begin
  s := '';
  params := JsParams(cx,obj,argc,argv);
  for i := 0 to high(params) do
  begin
    // check for string
    if not VarIsStr(params[i]) then
    begin
      writeln('error: jsh_cat param #',i,' is not string, filename required, skipped');
      continue;
    end;
    // check if file exists, load it
    if FileExists(params[i]) then
    begin
      with TStringList.Create do
      try
        LoadFromFile(params[i]);
        s := s + Text;
      finally
        Free;
      end;
    end;
  end;
  result := JsResult(s,cx,rval,@params);;
end;

begin
  JSRuntime := TFpcJsRunTime.Create();
  JSScript := JSRuntime.CreateScript();

  // bind special jsh functions
  JS_DefineFunction(JSScript.cx, JSScript.gl, 'jsh_cat_file', @jsh_cat_file, 0, JSPROP_ENUMERATE or JSPROP_EXPORTED);

  // include main library jsh.js
  if FileExists('jsh.js') then
    if not JSScript.EvaluateFile('jsh.js') then
      writeln('error: cannot evaluate implicit library "jsh.js"');

{  cmd := 'var s = cat("sample.txt"); echo(s.length);';

  // parse testing script
  parsed := JSScript.Evaluate(cmd);
  if not parsed then
    writeln('error: cannot evaluate script: '+cmd);
          }

  writeln;
  writeln('DONE');
  readln;

  // main loop
{  repeat
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
  until (cmd='q')or(cmd='quit')or(cmd='exit');}
end.

