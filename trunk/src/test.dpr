program test;

{*
Test for fpcjs
}

uses FpcJs;

const 
  source1 : string = 
    'echo("This is JS code\n\n");'+#10+ 
    'echo("Hello\n");'+#10+ 
    'echo("World\n\n"); '+#10+ 
    'echo("pi is "+3.14+" approximately, or ",3.14159," to be more precise\n")'+#10+ 
    'echo(Math.sqrt(2)," is sqrt 2\n");'+#10+ 
    'function greet(name,age,bmi,male,blood) { echo("hello "+age+"-year-old "+name+" has bmi ",bmi," is ",male," male and blood ",blood,"\n"); }; '+#10+
    'greet("John",95,2.78,true,"c");'+#10+ 
    'function foo(i) { echo("\n\nThis is foo\n\n"); }'+#10+ 
    'foo();'+#10+
    'function testAlphaBeta() { echo("testAlphaBeta:\n"); a = alpha(3.14,true,12,"kokos"); echo("alpha ok, vysledok="+a+"\n"); beta(); echo("beta ok\n"); return 123; }';
  source2 : string =
    'var step = 0; function fact(n) { step++; if (n <= 1) return 1; return n * fact(n-1); }'+#10+ 
    'echo("factorial 5 is ",fact(5),"\n");'+#10; 

var r : TFpcJsRuntime;
    s1,s2 : TFpcJsScript;
    
function alpha(AParams : TVariantArray) : variant;
var i : integer;
begin
  writeln('alpha(... ',High(AParams)+1,' params ...)');
  for i := 0 to High(AParams) do
    writeln('  param #',i,' = "',AParams[i],'"');
  writeln('alpha done');
  result := 'AlphaResult';
end;
    
function beta(AParams : TVariantArray) : variant;
begin
  writeln('beta: ...');
  result := true;
end;
    
begin
  // create runtime
  r := TFpcJsRuntime.Create;

  // create 2 scripts
  s1 := r.CreateScript;
  s2 := r.CreateScript;

  // evaluate 2 scripts
  if (not s1.Evaluate(source1))
  or (not s2.Evaluate(source2)) 
    then writeln('!!! EVALUATE ERROR !!!');

  // call js function from pascal
  s1.Call('greet',['Carry',16,3.14,false,'a']);
  
  // return value from js function
  writeln('factorial 7 is ',s2.Call('fact',[7]));
  
  // get js variable value
  writeln('step is ',s2.GetValue('step'));
  writeln('factorial 6 is ',s2.Call('fact',[6]));
  writeln('step is ',s2.GetValue('step'));
  
  // set js variable value
  s2.SetValue('step',100);
  s2.SetValue('step2',200);
  writeln('step is ',s2.GetValue('step'));
  writeln('step2 is ',s2.GetValue('step2'));
  writeln('step*10 is ',s2.GetValue('step')*10);

  // register sample functions
  s1.RegisterFunction('alpha',alpha);
  s1.RegisterFunction('beta',beta);
  
  // call that functions
  s1.Call('testAlphaBeta',['a']);

  // release variables
  //s1.Free;
  //s2.Free;
  r.Free;

  writeln('Press enter to exit');
  readln;  
end.
