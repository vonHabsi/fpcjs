// Extra library for JC, it is loaded on jc start

// basic help
var help = 
  "JC - JavaScript calculator, demo for fpcjs - http://code.google.com/p/fpcjs/\n"+
  "Type 'q', 'quit' or 'exit' to exit from JC\n"+
  "\n"+
  "Functions:\n"+
  "  abs, min, max\n"+
  "  cos, sin, tan, atan, atan2, acos, asin\n"+
  "  ceil, floor, round\n"+
  "  log, ln, exp\n"+
  "  sqr, sqrt, pow\n"+
  "  random\n"+
  "  fact\n"+
  "\nFor more help type help_<command>, e.g. help_log";
  
// avoid parse error on quit
var q = "quit"; 
var quit = "quit"; 
var exit = "quit";

// exported math functions to avoid typing of "Math." prefix
function abs(x)      { return Math.abs(x); }                  help_abs =    "abs(x) - the absolute value of x";
function acos(x)     { return Math.acos(x); }                 help_acos =   "acos(x) - arc cosine of x";
function asin(x)     { return Math.asin(x); }                 help_asin =   "asin(x) - arc sine of x";
function atan(x)     { return Math.atan(x); }                 help_atan =   "atan(x) - arc tangent of x";
function atan2(x,y)  { return Math.atan2(x,y); }              help_atan2 =  "atan2(x,y) - arc tangent of x/y";
function ceil(x)     { return Math.ceil(x); }                 help_ceil =   "ceil(x) - integer closest to a and not less than x";
function cos(x)      { return Math.cos(x); }                  help_cos =    "cos(x) - cosine of x";
function exp(x)      { return Math.exp(x); }                  help_exp =    "exp(x) - exponent of x";
function floor(x)    { return Math.floor(x); }                help_floor =  "floor(x) - integer closest to and not greater than x";
function log(x)      { return Math.log(x); }                  help_log =    "log(x) - log of a base x";
function max(x,y)    { return Math.max(x,y); }                help_max =    "max(x,y) - the maximum of x and y";
function min(x,y)    { return Math.min(x,y); }                help_min =    "min(x,y) - the minimum of x and y";
function pow(x,y)    { return Math.pow(x,y); }                help_pow =    "pow(x,y) - x to the power y";
function random()    { return Math.random(); }                help_random = "random() - pseudorandom number in the range 0 to 1";
function round(x)    { return Math.round(x); }                help_round =  "round(x) - integer closest to x"; 
function sin(x)      { return Math.sin(x); }                  help_sin =    "sin(x) - sine of x";
function sqrt(x)     { return Math.sqrt(x); }                 help_sqrt =   "sqrt(x) - square root of x";
function sqr(x)      { return x*x; }                          help_sqr =    "sqr(x) - square of x (equals x*x or x^2)";
function tan(x)      { return Math.tan(x); }                  help_tan =    "tan - tangent of x";
function ln(x)       { return Math.log(x)/Math.log(Math.E); } help_ln =     "ln(x) - natural logarithm, ln(x) = log(x) / log(e)";

// constants
var PI = Math.PI;
var E = Math.E;

// special functions
function fact(n) { 
  if (n <= 1) 
    return 1; 
  return 1 * n * fact(n-1); 
}

// clear screen hack
var cls = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
var clear = cls;

// real numbers displayed digits 
var scale = 2;

// first string in echo will indent all displayed results
var indent = '> ';
var suffix = '\n\n';

function avg(values) {
  // return average value of array values
  var sum = 0;
  for (var i=0; i<values.length; i++)
    sum += values[i];
  return sum / values.length;
}
