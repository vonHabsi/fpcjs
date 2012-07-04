unit fpcjs;

{*
Simplified JavaScript interface for FPC
http://code.google.com/p/fpcjs/

Features:
ok - creating multiple isolated runtimes
ok - creating multiple (not so isolated) scripts in one runtime
ok - evaluating scripts, return true/false on succes/fail
ok - calling special pascal functions from javascript:
  ok - echo
ok - calling script functions from pascal
  ok - parameters
  ok - return value
ok - js global variables
  ok - setting js variables from pascal
  ok - getting js variables from pascal
  ok - correct type (int/bool/string/real)
ok - calling own pascal functions from script
  ok - register it
  ok - execute callback
  ok - parameters
  ok - return value
ok - simplify process for binding native cdecl functions because current simple binding (via argv[-2]) doesnt work in linux so I have to use cdecl with difficult attributes

Requirements:

FPC 2.2.x
 + Linux: libmozjs.so
 + Windows: js3250.dll (e.g. from firefox 3, it will also require another 2 dll files from firefox - mozcrt19.dll, nspr4.dll)
  
TODO (someday):
- turtle demo 
- ???
}

{$IFDEF FPC}
{$MODE delphi}
{$ENDIF}

interface

uses SysUtils, Classes, js15decl, Variants;

type
  TFpcJsScript = class;

  TFpcJsRuntime = class(TList)
  protected
    rt : PJSRuntime;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function CreateScript : TFpcJsScript;
  end;

  TVariantArray = array of variant;
  PVariantArray = ^TVariantArray;

  TFpcJsCallback = function(AParameters : TVariantArray) : variant;
  
  { TFpcJsScript }

  TFpcJsScript = class
  protected
  public
    cx : PJSContext;
    gl : PJSObject;
    fu,fu1,fu2 : PJSFunction;
    Runtime : TFpcJsRuntime;
    constructor Create(ARuntime : TFpcJsRuntime); virtual;
    destructor Destroy; override;
    function Evaluate(ACode : string) : boolean;
    function EvaluateFile(AFileName : string) : boolean;
    function Call(AFunctionName : string; AParameters : array of const) : Variant;
    function GetValue(APropertyName : string) : variant; 
    function GetValueAsInteger(APropertyName : string) : integer; 
    function GetValueAsDouble(APropertyName : string) : double; 
    function GetValueAsString(APropertyName : string) : string; 
    function GetValueAsBoolean(APropertyName : string) : boolean; 
    function SetValue(APropertyName : string; APropertyValue : variant) : boolean;
    procedure RegisterFunction(AName : string; ACallback : TFpcJsCallback);
    function RegisterNative(AName : string; ANative : JsNative) : PJsFunction;
  end;

  TFpcJsCallbackItem = class
    Script : TFpcJsScript;
    Funct : PJSFunction;
    Name : string; 
    Callback : TFpcJsCallback;    
  end;
  
  TFpcJsCallbackList = class(TList)
    function FindFunction(APointer : pointer) : TFpcJsCallbackItem;
  end;

function JsParams(cx: PJSContext; obj: PJSObject; argc: uintN; argv : pjsval): TVariantArray;
function JsResult(AResult : variant; cx: PJSContext; rval : pjsval; AParams : PVariantArray): JSBool;
 
implementation

var FpcJsCallbackList : TFpcJsCallbackList;

{ Auxiliary functions }

function JsParams(cx: PJSContext; obj: PJSObject; argc: uintN; argv : pjsval): TVariantArray;
{*
Convert JS parameters to more simple variant variables, don'r forget to release them
}
var va : TVariantArray;
    i : integer;
    pom : pjsval;
begin
  setlength(va,argc);
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
      va[i] := null;
    if JSValIsVoid(pom^) then
      va[i] := null;
    if JSValIsObject(pom^) then
      va[i] := pom^;
    {if JSValIsNumber(pom^) then
      write('[Number]');}
    if JSValIsString(pom^) then
      va[i] := JSStringToString(JSValToJSString(pom^));
    if JSValIsInt(pom^) then
      va[i] := JSValToInt(pom^);
    if JSValIsDouble(pom^) then
      va[i] := JSValToDouble(cx,pom^);
    if JSValIsBoolean(pom^) then
      va[i] := JSValToBoolean(pom^);
  end;
  result := va;
end;

function JsResult(AResult : variant; cx: PJSContext; rval : pjsval; AParams : PVariantArray): JSBool;
begin
  // set return value
  if VarIsNumeric(AResult) then
    rval^ := IntToJSVal(AResult)
  else
  if VarIsFloat(AResult) then
    rval^ := DoubleToJSVal(cx,AResult)
  else
  if VarIsType(AResult,varBoolean) then
    rval^ := BoolToJSVal(AResult)
  else
    rval^ := StringToJSVal(cx,AResult);
  // result value
  result := JS_FALSE;
  if AResult <> NULL then
    result := JS_TRUE;
  SetLength(AParams^,0);
end;

function echo(cx: PJSContext; obj: PJSObject; argc: uintN; argv, rval: pjsval): JSBool; cdecl;
{*
When called from JS, it print all arguments to standard input, use \n for new line
Also this is excelent demo how to obtain parameters from JS call of pascal function because it handle all 4 data types (string,(long)int(eger),double,boolean)
}
var i,scale : integer;
    pom : pjsval;
    ss : JSVal;
begin
  // useful function for debuging purposes from javascript
  // if 'scale' variable is set, use it to determine number of visible digits
  scale := -1;
  if JS_GetProperty(cx,obj,pchar('scale'),@ss) = JS_TRUE then
    scale := JSValToInt(ss);
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
    begin
      if scale > 0 then
        write(JSValToDouble(cx,pom^):1:scale)
      else
      if scale = 0 then
        write(round(JSValToDouble(cx,pom^)))
      else
        write(JSValToDouble(cx,pom^));
    end;
    if JSValIsBoolean(pom^) then
      write(JSValToBoolean(pom^));
  end;
  Result := JS_TRUE;
end;

function fpcjs_write(cx: PJSContext; obj: PJSObject; argc: uintN; argv, rval: pjsval): JSBool; cdecl;
{*
Alias for echo(...);
}
begin
  result := echo(cx,obj,argc,argv,rval);
end;

function fpcjs_writeln(cx: PJSContext; obj: PJSObject; argc: uintN; argv, rval: pjsval): JSBool; cdecl;
{*
Alias for echo(...+'\n');
}
begin
  result := echo(cx,obj,argc,argv,rval);
  writeln;
end;

{ TFpcJsRuntime }

constructor TFpcJsRuntime.Create;
begin
  inherited;
  rt := JS_Init($100000);
end;

destructor TFpcJsRuntime.Destroy;
var i : integer;
begin
  for i := Count-1 downto 0 do
    if TFpcJsScript(Items[i]).Runtime = self then 
      TFpcJsScript(Items[i]).Free;
  JS_Finish(rt); 
  inherited;
end;

function TFpcJsRuntime.CreateScript : TFpcJsScript;
{*
Create new script and add it to runtime
}
begin
  result := TFpcJsScript.Create(self);
  Add(result);
end;

{ TFpcJsScript }

{$IFNDEF FPC}
const
  global_class: JSClass = (name: 'global'; flags: JSCLASS_HAS_PRIVATE; addProperty: JS_PropertyStub;
                           delProperty: JS_PropertyStub; getProperty: JS_PropertyStub; setProperty: JS_PropertyStub;
                           enumerate: JS_EnumerateStub; resolve: JS_ResolveStub; convert: JS_ConvertStub;
                           finalize: JS_FinalizeStub );
{$ENDIF}

constructor TFpcJsScript.Create(ARuntime : TFpcJsRuntime);
begin
  inherited Create;
  Runtime := ARuntime;
  cx := JS_NewContext(ARuntime.rt, $1000);
  gl := JS_NewObject(cx,@global_class,nil,nil);
  try
	  JS_InitStandardClasses(cx, gl);
  except
  	on e:Exception do
	  	writeln('Error JS_InitStandardClasses: ',e.Message);
  end;
  fu := JS_DefineFunction(cx, gl, 'echo', @echo, 0, JSPROP_ENUMERATE or JSPROP_EXPORTED);
  fu1 := JS_DefineFunction(cx, gl, 'write', @fpcjs_write, 0, JSPROP_ENUMERATE or JSPROP_EXPORTED);
  fu2 := JS_DefineFunction(cx, gl, 'writeln', @fpcjs_writeln, 0, JSPROP_ENUMERATE or JSPROP_EXPORTED);
end;

destructor TFpcJsScript.Destroy;
var i : integer;
begin
  if Assigned(Runtime) then
    for i := Runtime.Count-1 downto 0 do
      if TFpcJsScript(Runtime[i]) = self then 
        Runtime.Delete(i);
  //JS_DestroyContext(cx);
  inherited;
end;

function TFpcJsScript.Evaluate(ACode : string) : boolean;
{*
Evaluate script return true if successfull
}
var filename : PChar;
    lineno : integer;
    rval : JSVal;  
begin
  filename := nil;
  lineno := 0;
  result := JS_EvaluateScript(cx, gl, pchar(ACode), length(ACode), filename, lineno, @rval) = JS_TRUE;
end;

function TFpcJsScript.EvaluateFile(AFileName: string): boolean;
{*
Open js file and evaluate its content as js source code
}
begin
  with TStringList.Create do
  try
    LoadFromFile(AFileName);
    result := Evaluate(Text);
  finally
    Free;
  end;
end;

function TFpcJsScript.Call(AFunctionName : string; AParameters : array of const) : Variant;
{*
Evaluate javascript function from pascal
}
var a : array of jsval;
    i : integer;
    s : string;
    jstr : PJSString;
    jb : JSBool;
    rval : JSVal;
begin
  // cal test function with multiple different parameters
  SetLength(a, length(AParameters));
  for i := 0 to length(AParameters)-1 do
    case AParameters[i].VType of
{      vtBoolean: writeln(i,'. je boolean');
      vtExtended: writeln(i,'. je extended');}
      vtInteger: a[i] := IntToJSVal(AParameters[i].VInteger);
      vtAnsiString: begin
        s := AnsiString(AParameters[i].VAnsiString);
        a[i] := JSStringToJSVal(
          JS_NewString(cx,
          pchar(s),
          length(s)+1)
        );
      end;
      vtChar: begin
        s := AParameters[i].VChar;
        a[i] := JSStringToJSVal(
          JS_NewString(cx,
          pchar(s),
          length(s)+1)
        );
      end;
      vtBoolean: a[i] := BoolToJSVal(AParameters[i].VBoolean);
      vtExtended: a[i] := DoubleToJSVal(cx,AParameters[i].VExtended^);
    else
      writeln('FATAL: ',i,'. is unknown type');
      halt(1);
    end;
  // call the function
  jb := JS_CallFunctionName(cx,gl,pchar(AFunctionName),Length(a),@a[0],@rval);
  // return
  if jb=JS_TRUE then
  begin
    jstr := JS_ValueToString(cx, rval);
    result := string(JS_GetStringBytes(jstr));
  end else
    result := ''; 
end; 

function TFpcJsScript.GetValue(APropertyName : string) : variant;
{*
Get value of js variable
}
var jb : JSBool;
    rval : JSVal;
begin
  jb := JS_GetProperty(cx,gl,pchar(APropertyName),@rval);
  if jb = JS_TRUE then
  begin
    result := NULL;
    if JSValIsString(rval) then result := JSStringToString(JSValToJSString(rval));
    if JSValIsInt(rval) then result := JSValToInt(rval);
    if JSValIsDouble(rval) then result := JSValToDouble(cx,rval);
    if JSValIsBoolean(rval) then result := JSValToBoolean(rval);
    //result := JS_GetStringBytes((JS_ValueToString(cx, rval)))
  end
  else begin
    writeln('error: undefined property "',APropertyName,'"'); 
    result := NULL;
  end; 
end;

function TFpcJsScript.GetValueAsInteger(APropertyName : string) : integer;
{*
Get integer value of js variable
}
var rval : JSVal;
begin
  if JS_GetProperty(cx,gl,pchar(APropertyName),@rval) = JS_TRUE then
    result := JSValToInt(rval)
  else begin
    writeln('error: undefined property "',APropertyName,'"'); 
    result := NULL;
  end; 
end;
 
function TFpcJsScript.GetValueAsDouble(APropertyName : string) : double; 
{*
Get double value of js variable
}
var rval : JSVal;
begin
  if JS_GetProperty(cx,gl,pchar(APropertyName),@rval) = JS_TRUE then
    result := JSValToDouble(cx,rval)
  else begin
    writeln('error: undefined property "',APropertyName,'"'); 
    result := NULL;
  end; 
end;
 
function TFpcJsScript.GetValueAsString(APropertyName : string) : string; 
{*
Get string value of js variable
}
var rval : JSVal;
begin
  if JS_GetProperty(cx,gl,pchar(APropertyName),@rval) = JS_TRUE then
    result := JSStringToString(JSValToJSString(rval))
  else begin
    writeln('error: undefined property "',APropertyName,'"'); 
    result := NULL;
  end; 
end;

function TFpcJsScript.GetValueAsBoolean(APropertyName : string) : boolean;
{*
Get boolean value of js variable
}
var rval : JSVal;
begin
  if JS_GetProperty(cx,gl,pchar(APropertyName),@rval) = JS_TRUE then
    result := JSValToBoolean(rval)
  else begin
    writeln('error: undefined property "',APropertyName,'"'); 
    result := NULL;
  end; 
end; 

function TFpcJsScript.SetValue(APropertyName : string; APropertyValue : variant) : boolean; 
{*
Set value of js variable
}
var jb : JSBool;
    rval : JSVal;
begin
  // set return value
  if VarIsType(APropertyValue,varBoolean) then
    rval := BoolToJSVal(APropertyValue)
  else
  if VarIsFloat(APropertyValue) then
    rval := DoubleToJSVal(cx,APropertyValue)
  else
  if VarIsNumeric(APropertyValue) then
    rval := IntToJSVal(APropertyValue)
  else
    rval := StringToJSVal(cx,APropertyValue);
  //rval := StringToJSVal(cx, APropertyValue);
  jb := JS_SetProperty(cx,gl,PChar(APropertyName),@rval);
  result := jb = JS_TRUE;
end;

function fpc_global_callback(cx: PJSContext; obj: PJSObject; argc: uintN; argv, rval: pjsval): JSBool; cdecl;
{*
Container for all function calls
}
var tmpv : pjsval;
    bridge: PJSObject;
    itm : TFpcJsCallbackItem;
    va : TVariantArray;
    rv : variant;
begin
  //writeln('fpc_global_callback: cx=',longword(cx),' obj=',longword(obj),' argc=',argc);
  // epic hack - access argv[-2] to get the value of |this| which equals to js function pointer  
  tmpv := argv;
  dec(tmpv,2); 
  bridge := PJSObject(tmpv^);
  // find real function callback by given pointer to that function     
  itm := FpcJsCallbackList.FindFunction(bridge);
  if itm = nil then
  begin 
    writeln('error: call to undeclared function, cx=',longword(cx),' obj=',longword(obj),' argc=',argc,' bridge=',longword(bridge));
    result := JS_FALSE;
    exit;
  end;
  // convert arguments of js values to variant array
  va := JsParams(cx,obj,argc,argv);
  // call
  rv := itm.Callback(va);
  // release params
  //FIXME: this crash for some reasons
  {$ifdef FPC}
  result := JsResult(rv,cx,rval,@va);
  {$else}
  writeln('//FIXME: fpc_global_callback - undefined result for DELPHI');
  result := JS_FALSE;
  {$endif}
end;    

procedure TFpcJsScript.RegisterFunction(AName : string; ACallback : TFpcJsCallback);
{*
Register global callback function to call from js
}
var i : TFpcJsCallbackItem;
    {ncx : PJSContext;
    ngl,ngl2 : PJSObject;}
begin
  i := TFpcJsCallbackItem.Create;
  i.Script := self;
  i.Name := AName;
  {$ifndef FPC}
  writeln('warning: TFpcJsScript.RegisterFunction may not work in Delphi');
  {$endif}
  i.Funct := JS_DefineFunction(cx, gl, pchar(AName), @fpc_global_callback, 0, JSPROP_ENUMERATE);
  //ncx := JS_NewContext(Runtime.rt, $1000);
  //ngl := JS_NewObject(cx,@intf_bridge_method_class,nil,gl);
  //ngl2 := JS_DefineObject(cx,gl,'novy',@intf_bridge_method_class,nil,JSPROP_ENUMERATE);
  //writeln('RegisterFunction: ncx=',longword(cx),' ngl=',longword(ngl2),' script=',longword(self),' funct=',longword(i.Funct),' callback=',longword(@ACallback));
  i.Callback := ACallback;
  fpcJsCallbackList.Add(i);
end;

function TFpcJsScript.RegisterNative(AName : string; ANative : JsNative) : PJsFunction;
{*
Register native function
}
begin
  result := JS_DefineFunction(cx, gl, pchar(AName), @ANative, 0, JSPROP_ENUMERATE); 
end;

function TFpcJsCallbackList.FindFunction(APointer : pointer) : TFpcJsCallbackItem;
{*
Podla pointera na funkciu v items najde tu funkciu a vrati danu item
}
var i : integer;
begin
  result := nil;
  for i := 0 to Count-1 do
    if TFpcJsCallbackItem(Items[i]).Funct = APointer then
      result := TFpcJsCallbackItem(Items[i]);  
end; 

initialization

  FpcJsCallbackList := TFpcJsCallbackList.Create;

finalization

  FpcJsCallbackList.Free;

end.
