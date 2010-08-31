// Extra library for JC, it is loaded on jc start

// basic help
var help = 
  "JC - JavaScript calculator, demo for fpcjs - http://code.google.com/p/fpcjs/\n"+
  "Type 'q', 'quit' or 'exit' to exit from JC\n"+
  "\n"+
  "Functions:\n"+
  "  abs\n"+
  "  acos\n"+
  "  asin\n"+
  "  atan\n"+
  "  atan2\n"+
  "  ceil\n"+
  "  cos\n"+
  "  exp\n"+
  "  fact\n"+
  "  floor\n"+
  "  log\n"+
  "  max\n"+
  "  min\n"+
  "  pow\n"+
  "  random\n"+
  "  round\n"+ 
  "  sin\n"+
  "  sqrt\n"+
  "  tan\n"+
  "\n";
  
// help for functions
var help_sqrt = "--> sqrt(x : real) : real <-- calculate square root of X"

// avoid parse error on quit
var q = "quit"; 
var quit = "quit"; 
var exit = "quit";

// exported math functions to avoid typing of Math.
function abs(x)      { return Math.abs(x); }      help_abs =    "abs(x) - the absolute value of x";
function acos(x)     { return Math.acos(x); }     help_acos =   "acos(x) - arc cosine of x"
function asin(x)     { return Math.asin(x); }     help_asin =   "asin(x) - arc sine of x"
function atan(x)     { return Math.atan(x); }     help_atan =   "atan(x) - arc tangent of x"
function atan2(x,y)  { return Math.atan2(x,y); }  help_atan2 =  "atan2(x,y) - arc tangent of x/y"
function ceil(x)     { return Math.ceil(x); }     help_ceil =   "ceil(x) - integer closest to a and not less than x"
function cos(x)      { return Math.cos(x); }      help_cos =    "cos(x) - cosine of x"
function exp(x)      { return Math.exp(x); }      help_exp =    "exp(x) - exponent of x"
function floor(x)    { return Math.floor(x); }    help_floor =  "floor(x) - integer closest to and not greater than x"
function log(x)      { return Math.log(x); }      help_log =    "log(x) - log of a base x"
function max(x,y)    { return Math.max(x,y); }    help_max =    "max(x,y) - the maximum of x and y"
function min(x,y)    { return Math.min(x,y); }    help_min =    "min(x,y) - the minimum of x and y"
function pow(x,y)    { return Math.pow(x,y); }    help_pow =    "pow(x,y) - x to the power y"
function random()    { return Math.random(); }    help_random = "random() - pseudorandom number in the range 0 to 1"
function round(x)    { return Math.round(x); }    help_round =  "round(x) - integer closest to x" 
function sin(x)      { return Math.sin(x); }      help_sin =    "sin(x) - sine of x"
function sqrt(x)     { return Math.sqrt(x); }     help_sqrt =   "sqrt(x) - square root of x"
function tan(x)      { return Math.tan(x); }      help_tan =    "tan - tangent of x"

// constants
var PI = Math.PI;
var E = Math.E;

// special functions
function fact(n) { 
  if (n <= 1) 
    return 1; 
  return n * fact(n-1); 
}

// clear screen hack
var cls = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
var clear = cls;

//var scale = 2;