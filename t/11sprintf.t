use strict;
use warnings;
use Math::NV qw(:all);

print "1..2\n";

my $nv = 67.625;

eval {Cprintf("%.10f\n", $nv);};

if(!$@) {print "ok 1\n"}
else {
  warn "\$\@: $@";
  print "not ok 1\n";
}

my $str = Csprintf("%.10f", $nv, 20);

if($str eq '67.6250000000') {print "ok 2\n"}
else {
  warn "\$str: $str\n";
  print "not ok 2\n";
}




