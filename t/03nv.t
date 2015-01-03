use strict;
use warnings;
use Math::NV qw(:all);

print "1..3\n";

# Test with values for which perl and C will (hopefully) agree.

my($nv, $iv) = nv('123.625');

if($nv == 123.625) {print "ok 1\n"}
else {
  warn "\nExpected 123.625\nGot $nv\n";
  print "not ok 1\n";
}

if($iv == 0) {print "ok 2\n"}
else {
  warn "\nExpected 0\nGot $iv\n";
  print "not ok 2\n";
}

$nv = nv('-1125e-3');

if($nv == -1.125) {print "ok 3\n"}
else {
  warn "\nExpected -1.125\nGot $nv\n";
  print "not ok 3\n";
}
