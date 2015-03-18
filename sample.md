Unlike original/official Delphi JavaScript bridge, which is due to its complexness not compileable in FPC (FreePascal) and/or doesn't work really well, is too big, bloated and outdated, this project use only js15decl.pas (basically C header) interface from the original bridge and add very small (simple and maintainable) wrapper around it to simplify the usage of Mozilla JavaScript engine in FPC. It also contain set of minimal working demos how to do basic JS stuff from FPC like call JS function, set JS variable, call FPC function from JS, etc... Please use SVN to download the project.
API Overview

If you want to use FpcJs, you need add uses clause first.

```pascal
uses FpcJs;
```

This gives you access to 2 main objects - TFpcJsRuntime and TFpcJsScript.

```pascal
var r : TFpcJsRuntime;
    s : TFpcJsScript;
```
To actually access JavaScript, create runtime and then script object. Usual way is to have single runtime and multiple scripts. Created scripts belongs to runtime.

```pascal
r := TFpcJsRuntime.Create;
s := r.CreateScript;
```
Once you have script object, you can compile actual JavaScript source code. Note that this will also execute the code! If source code evaluation failed (e.g. because of syntax error), it will return FALSE.

```pascal
if not s.Evaluate('var a=22, b=7, i=5, b=true, s="asdf", r=2.78; echo("pi is approximately ",a/b,"\n");') then
  writeln('error: evaluation failed');
```

Example above will write:

`pi is approximately  3.142857142857143E+000`

You can easily get values of JavaScript global variables with GetValue:

```pascal
writeln('i=',s.GetValue('i'),' b=',s.GetValue('b'),' s=',s.GetValue('s'),' r=',real(s.GetValue('r')):1:5);
```

Will print:

`i=5 b=True s=asdf r=2.78000`

You can change these variables with SetValue:

```pascal
s.SetValue('i',6);
s.SetValue('b',false);
s.SetValue('s','qwer');
s.SetValue('r',1.68);
```

If you print variables now, you will see new values. This code:

```pascal
writeln('i=',s.GetValue('i'),' b=',s.GetValue('b'),' s=',s.GetValue('s'),' r=',real(s.GetValue('r')):1:5);
```

Will print:

`i=6 b=False s=qwer r=1.68000`

With SetValue, you can set variable which even doesn't exist. It will create it automatically.

```pascal
s.SetValue('n',123);
writeln('n=',s.GetValue('n'));
```

Will print:

`n=123`

Probably most important part is binding pascal functions to be called from JavaScript, and calling JavaScript functions from pascal. Both tasks are very simple.

First, let's create some JavaScript function, for example factorial:

```pascal
if not s.Evaluate('function fact(n) { if (n <= 1) return 1; return n * fact(n-1); }') then
  writeln('error: evaluation failed');
```
You can now call it with method Call. Function is identified by its name and parameters are passed as array of variants. Result is also retrieved as variant. Following code:

```pascal
writeln('factorial 5 is ',s.Call('fact',[5]));
```

Will print:

`factorial 5 is 120`

If you want to bind pascal function for use in JavaScript, use RegisterFunction. First create some pascal function. This one print PI with given amount of decimal digits:

```Pascal
function myPi(AParams : TVariantArray) : variant;
var i : integer;
begin
  i := AParams[0];
  if i > 10 then i := 10;
  if i < 1 then i := 1;
  result := Format('%1.'+inttostr(i)+'f',[pi]);
end;
```
Above function attributes are "AParams : TVariantArray" and result is "variant". This is the one and only kind of function that can be bind. You cannot have function with different attributes or different result type. You even cannot bind procedures or objects methods.

Once pascal function is created, you can bind it with corresponding name to script:

```pascal
s.RegisterFunction('pi',myPi);
```
Then you can create script which will use this function:

if not s.Evaluate('echo("pi is actually ",pi(5),"\n");') then
  writeln('error: evaluation 2 failed');

Will print:

`pi is actually 3,14159`

As you may noticed, there is allready one function binded for all scripts. This function is function "echo" which will print all it's attributes to stdout. It can be used for whatever purposes, e.g. debugging. It convert '\n' to new line.

And that's it. Pretty simple isn't it?

Unfortunately, there is some bug in Linux version of libmozjs. So in Linux, you cannot use TScript.RegisterFunction, you have to use TScript.RegisterNative and bind only native functions. That is because on Linux, argv[-2] doesn't point to PJsFunction object declared with JS_DefineFunction. Why? I don't know. Previous myPi function will look like this:

```pascal
function myPi(cx: PJSContext; obj: PJSObject; argc: uintN; argv, rval: pjsval): JSBool; cdecl; 
var i : integer; 
    params : TVariantArray; 
begin 
  // print pi on specified amount of digits 
  params := JsParams(cx,obj,argc,argv); 
  i := params[0]; 
  if i > 10 then i := 10; 
  if i < 1 then i := 1; 
  result := JsResult(Format('%1.'+inttostr(i)+'f',[pi]),cx,rval,@params); 
end; 
```
This incorporate 2 special functions - JsParams and JsResult. These functions convert JS parameters and set JS result. It also allocate and release local function params. This will eventually be fixed someday. Meanwhile, use RegisterNative if you want portable applications.

JavaScript console calculator demo

