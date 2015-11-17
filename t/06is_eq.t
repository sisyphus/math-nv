use strict;
use warnings;
use Math::NV qw(:all);

print "1..3\n";

$Math::NV::no_warn = 1; # avoid warning that arg is not a string

if(is_eq(125)) {print "ok 1\n"}
else {print "not ok 1\n"}

$Math::NV::no_warn = 0; # re-enable the warning

if($Math::NV::no_mpfr) {
  warn "\nMath::MPFR not available - skipping remaining tests";
  print "ok 2\nok 3\n";

}
else {

  if(is_eq_mpfr('2.3')) {print "ok 2\n"}
  else {print "not ok 2\n"}

######################################

  $Math::NV::no_mpfr = 1;

  eval {is_eq_mpfr('2.3');};

  if($@ =~ /^In is_eq_mpfr\(\): 1/) {print "ok 3\n"}
  else {
    warn "\n\$\@: $@\n";
    print "not ok 3\n";
  }

  $Math::NV::no_mpfr = 0;
######################################

}
