program test3;

{*
Isolated test for native pascal function binding

}

{$ifdef FPC}
{$mode DELPHI}
{$else}
{$apptype CONSOLE}
{$endif}

uses
  SysUtils, Classes,
  js15decl in '..\libmozjs\js15decl.pas';

function echo(cx: PJSContext; obj: PJSObject; argc: uintN; argv, rval: pjsval): JSBool; cdecl;
{*
When called from JS, it print all arguments to standard input, use \n for new line
Also this is excelent demo how to obtain parameters from JS call of pascal function because it handle all 4 data types (string,(long)int(eger),double,boolean)
}
var i : integer;
    pom : pjsval;
begin
  // useful function for debuging purposes from javascript
  //writeln('-- this is echo with ',argc,' arguments obj=',longword(obj),' --');
  for i := 0 to argc-1 do
  begin
    {$ifndef fpc}
    // inc(argv,i); pom := pjsval(argv^); dec(argv,i);}   // this original code does not work in delphi 7
    // pom := TArrayOfPjsval(argv)[i];                    // for some reason this is not working either, assuming type TArrayOfPjsval = array of pjsval;
    pom := pjsval(integer(argv)+i*sizeof(pjsval));        // working hack
    {$else}
    pom := pjsval(argv+i);
    {$endif}
    if JSValIsNull(pom^) then
      write('[Null]');
    if JSValIsVoid(pom^) then
      write('[Void]');
    if JSValIsObject(pom^) then
      write('[Object]');
    {if JSValIsNumber(pom^) then
      write('[Number]');}
    if JSValIsString(pom^) then
      write(JSStringToString(JSValToJSString(pom^)));
    if JSValIsInt(pom^) then
      write(JSValToInt(pom^));
    if JSValIsDouble(pom^) then
      write(JSValToDouble(cx,pom^));
    if JSValIsBoolean(pom^) then
      write(JSValToBoolean(pom^));
  end;
  Result := JS_TRUE;
end;

{$IFNDEF FPC}
const
  global_class: JSClass = (name: 'global'; flags: JSCLASS_HAS_PRIVATE; addProperty: JS_PropertyStub;
                           delProperty: JS_PropertyStub; getProperty: JS_PropertyStub; setProperty: JS_PropertyStub;
                           enumerate: JS_EnumerateStub; resolve: JS_ResolveStub; convert: JS_ConvertStub;
                           finalize: JS_FinalizeStub );
{$ENDIF}

const 
	source = 'var a=6; var b=7; echo("answer is ",a*b,"\n");';

var
	rt : PJSRuntime;
    cx : PJSContext;
    gl : PJSObject;
    fu : PJSFunction;
    rval : JSVal;

begin
	rt := JS_Init($100000);
	cx := JS_NewContext(rt, $1000);
	gl := JS_NewObject(cx,@global_class,nil,nil);
	try
		JS_InitStandardClasses(cx, gl);
	except
		on e:Exception do
			writeln('Error JS_InitStandardClasses: ',e.Message);
	end;
	fu := JS_DefineFunction(cx, gl, 'echo', @echo, 0, JSPROP_ENUMERATE or JSPROP_EXPORTED);
  writeln('function binding: ',integer(fu));
	if JS_EvaluateScript(cx, gl, pchar(source), length(source), nil, 0, @rval) = JS_TRUE then
		writeln('evaluate ok')
	else
		writeln('EVALUATE ERROR');
  writeln('press enter');
  readln;
end.
