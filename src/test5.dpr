program test5;

{*
Test5 - objects
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
  parsed : boolean;

// pascal object we want to use in js

type
  TPascalTurtle = class
  private
    obj : PJSObject;
  public
    Name : string;
    X,Y : integer;
    procedure Go;
  end;
  
procedure TPascalTurtle.Go;
begin
  // move turtle to X+1,Y
  writeln('This is ',ClassName,'.Go for obj=',integer(obj),' (',Name,')');
  X := X+1;
end;

var TurtleList : TList;

procedure TurtleAttributesToJs(APascalTurtle : TPascalTurtle; cx : PJSContext; obj : PJSObject);
var jv : JSVal;
begin
  // our pascal turtle object has some attributes, we want them in js too
	// set up properties values
  jv := StringToJSVal(cx, APascalTurtle.Name);
  JS_SetProperty(cx,obj,'Name',@jv);
  jv := IntToJSVal(APascalTurtle.X);
  JS_SetProperty(cx,obj,'X',@jv);
  jv := IntToJSVal(APascalTurtle.Y);
  JS_SetProperty(cx,obj,'Y',@jv);
end;

function Turtle_Go(cx: PJSContext; obj: PJSObject; argc: uintN; argv, rval: pjsval): JSBool; cdecl;
var t : TPascalTurtle;
    i : integer;
begin
  writeln('This is Turtle_Go for obj=',integer(obj));
  // find pascal object by obj
  t := nil;
  for i := 0 to TurtleList.Count-1 do
    if TPascalTurtle(TurtleList[i]).obj = obj then
      t := TPascalTurtle(TurtleList[i]);
  if t = nil then
    raise Exception.Create('Cannot find turtle by obj');
  // call Go
  t.Go;  
  // replicate attributes
  TurtleAttributesToJs(t,cx,obj);
  // done
  result := JS_TRUE;
end;

function Turtle(cx: PJSContext; obj: PJSObject; argc: uintN; argv, rval: pjsval): JSBool; cdecl;
var t : TPascalTurtle;
    par : TVariantArray;
begin
  writeln('Creating Turtle object for obj=',integer(obj));
  // parse params to simpler format
  par := JsParams(cx, obj, argc, argv);
  // create pascal object of turtle
  t := TPascalTurtle.Create;
  t.Name := par[0];
  t.X := par[1];
  t.Y := par[2];
  t.obj := obj;
  TurtleList.Add(t);
  // register Go method for Turtle
	JS_DefineFunction(cx, obj, 'Go', @Turtle_Go, 0, JSPROP_ENUMERATE or JSPROP_EXPORTED);
  // replicate attributes
  TurtleAttributesToJs(t,cx,obj);
	// done  
  Result := JS_TRUE;
end;

begin
  JSRuntime := TFpcJsRunTime.Create();
  JSScript := JSRuntime.CreateScript();

  JsScript.RegisterNative('Turtle',Turtle);

  TurtleList := TList.Create;

  // evaluate script
  parsed := JSScript.Evaluate('var Alice = new Turtle("Alice", 4, 3); var Bob = new Turtle("Bob", 10, 10); info(); Alice.Go(); Bob.Go(); info(); function info() { echo("INFO: Alice is at "+Alice.X+","+Alice.Y+", Bob is at "+Bob.X+","+Bob.Y+"\n"); }');
  if not parsed then
    writeln('Error #1 - evaluation failed'); 
      
{
This is what you will see:
  
Creating Turtle object for obj=135234496
Creating Turtle object for obj=135234528
INFO: Alice is at 4,3, Bob is at 10,10
This is Turtle_Go for obj=135234496
This is TPascalTurtle.Go for obj=135234496 (Alice)
This is Turtle_Go for obj=135234528
This is TPascalTurtle.Go for obj=135234528 (Bob)
INFO: Alice is at 5,3, Bob is at 11,10

}

  writeln('Press enter to exit');
  readln;  
end.