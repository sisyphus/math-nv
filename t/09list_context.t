use strict;
use warnings;
use Math::NV qw(:all);

print "1..1\n";

my($num, $ignored) = nv('10.5xtras');

if($num == 10.5 && $ignored == 5) {print "ok 1\n"}
else {
  warn "\n \$num: $num\n \$ignored: $ignored\n";
  print "not ok 1\n";
}

