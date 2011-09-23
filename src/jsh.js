// jsh main library

// core bindings

function cat(AFileName) {
  // load local file and split it into array separated by EOL
  return jsh_cat_file(AFileName).split('\n');
}

function dump(AInput,ANote) {
  // echo array to stdout for debug purposes
  echo(ANote+':\n');
  for (var i = 0; i < AInput.length; i++)
    echo('  ['+i+']: '+AInput[i]+'\n');
  echo('\n\n');
}

// filters

function grep(AInput,AWord) {
  // keep only array items containing certain words
  var n = new Array();
  for (var i = 0; i < AInput.length; i++)
    if (AInput[i].match(AWord))
      n.push(AInput[i]);
  return n;
}

function sed(AInput,AFind,AReplace) {
  // find words and replace them with new meaning
  var n = new Array();
  for (var i = 0; i < AInput.length; i++) {
    var s = AInput[i].replace(AFind,AReplace).split('\n');
    for (var j=0; j < s.length; j++)
      n.push(s[j]);
  }
  return n;
}

// testing code

function test() {
  var a = cat('sample.txt');
  dump(a,'1');

  var a = grep(a,'object');
  dump(a,'2');

  var a = sed(a,':','');
  dump(a,'3');

  var a = sed(a,/ /g,'\n');
  dump(a,'4');

  var a = grep(a,'qrl');
  dump(a,'5');

  for (var i in a)
    echo('  '+a[i]+'.Caption := inttostr(a[][]);\n');
}

s = "cat 'sample.txt' | grep 'object' | sed ':' '' | sed ' ' '\n' | grep 'qrl' | for (var i in a) echo '  '+a[i]+'.Caption := inttostr(a[][]);\n';";
echo(s+'\n\n');

a = s.split('|');
dump(a,'a');

function trim(AText) {
  return AText.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
}

for (var i=0; i<a.length; i++) {
  // first command in pipe
  aa = trim(a[i]);
  echo('aa='+aa+"\n");

  // split commend in command and attributes
  // TODO: must parse by characters to understand quotes
  cc = aa.split(' ');
  dump(cc,'cc');

  // convert it to jsh command
  echo('>>>  x = '+cc[0]+'(x,'+cc[1]+');\n');
}


/*

cat 'sample.txt' | grep object | sed ':' '' | sed ' ' '\n' | grep 'qrl' | for (var i in a) echo '  '+a[i]+'.Caption := inttostr(a[][]);\n';

cat sample.txt | grep object | sed ':' '' | sed ' ' '\n' | grep qrl | foreach echo '  %.Caption := inttostr(a[][]);\n';

*/

