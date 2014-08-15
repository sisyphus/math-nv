
# Test for a couple of specific (rare) compiler/libc bugs
# regarding doubles, and issue warnings if# bug is present -
# and a "FAIL" if the compiler/libc is producing a wrong
# result.

use strict;
use warnings;
use Math::NV qw(:all);
use POSIX;

print "1..1\n";

if(mant_dig() == 106) {
  warn "\nSkip - this test script needs Data::Float, but that\n",
        "module doesn't work on this architecture\n";
  print "ok 1\n";
  exit 0;
}

my $ok = 1;

require Data::Float; Data::Float->import('float_hex');

if(Math::NV::_bug_95e20() != nv('95e20')) {
  warn "\nAs regards 95e20:\n", " FYI: Your C compiler/libc is buggy - it evaluates\n",
       " 95e20 and strtod(\"95e20\", NULL) differently\n";

  my $num = POSIX::strtod('95e20');
  if($num == nv('95e20')) {
    warn " POSIX::strtod reports the same as your compiler/libc strtod\n";
  }
  else {
    warn " POSIX::strtod and your compiler/libc strtod differ\n";
  }
  warn " Correct hex value is: +0x1.017f7df96be18p+73\n";
  warn " POSIX::strtod yields: ", float_hex(scalar POSIX::strtod('95e20')), "\n";
  warn " C compiler/libc says: ", float_hex(scalar nv('95e20')), "\n";
  $ok = 0 unless lc(float_hex(scalar nv('95e20'))) eq '+0x1.017f7df96be18p+73';
  warn "\n";
}

if(Math::NV::_bug_1175557635e10() != nv('1175557635e10')) {
  warn "\nAs regards 1175557635e10:\n", " FYI: Your C compiler/libc is buggy - it evaluates\n",
       " 1175557635e10 and strtod(\"1175557635e10\", NULL) differently\n";

  my $num = POSIX::strtod('1175557635e10');
  if($num == nv('1175557635e10')) {
    warn " POSIX::strtod reports the same as your compiler/libc strtod\n";
  }
  else {
    warn " POSIX::strtod and your compiler/libc strtod differ\n";
  }
  warn " Correct hex value is: +0x1.464864d02f776p+63\n";
  warn " POSIX::strtod yields: ", float_hex(scalar POSIX::strtod('1175557635e10')), "\n";
  warn " C's strtod says     : ", float_hex(scalar nv('1175557635e10')), "\n";
  warn " C assigns           : ", float_hex(Math::NV::_bug_1175557635e10()), "\n";
  $ok = 0 unless lc(float_hex(scalar nv('1175557635e10'))) eq '+0x1.464864d02f776p+63';
  warn "\n";
  warn "\n";
}

if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}


__END__

Also:
1175557635e10
