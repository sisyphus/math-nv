use strict;
use warnings;
use Config;
use Math::NV qw(:all);

my $tests = 1;

print "1..$tests\n";

if($Config{nvsize} > 8 && $Config{osvers} =~ /powerpc/i) {
  warn "Skipping tests - Data::Float doesn't work on this architecture\n";
  for(1 .. $tests) {print "ok $_\n"}
  exit 0;
}

require Data::Float; Data::Float->import('float_hex');

if(mant_dig() != 53 && mant_dig() != 64) {
  warn "Skipping tests - they don't accommodate an NV that has a ", mant_dig(), "-bit mantissa\n";
  for(1 .. $tests) {print "ok $_\n";}
}

my $needed = 0;
my $ok = 1;

warn "Setting \$nv to 69659e-292\n";

my $nv = '69659e-292';
my $correct = nv_type() eq 'double' ? '+0x1.0f8a1ebc5050cp-954'
                                    : '+0x1.0f8a1ebc5050c800p-954';

if($nv == nv('69659e-292')) {
  warn"1. Perl and C agree that 69659e-292 is $nv\n";
}
else {
  warn "1. Perl thinks that 69659e-292 looks like ", float_hex($nv), "\n";
  warn "1. C    thinks that 69659e-292 looks like ", float_hex(scalar nv('69659e-292')), "\n";
  $needed = 1;
}

if("$nv" eq '69659e-292') {
  warn "2. \$nv stringifies to 69659e-292 as expected\n";
}
else {
  warn "2. \$nv surprisingly stringifies to $nv\n";
  $needed = 1;
}

if(float_hex($nv) eq $correct) {
  warn "3. $nv is ", float_hex($nv), " as expected\n";
}
else {
  warn "3. Perl sets $nv (wrongly) to ", float_hex($nv), "\n";
  $needed = 1;
}

if(float_hex(scalar nv("69659e-292")) eq $correct) {print "ok 1\n"}
else {
  warn "\$nv: $nv ", float_hex($nv), "\n";
  warn "nv(\$nv): ", nv("$nv"), " ", float_hex(scalar nv("$nv")), "\n";
  $ok = 0;
  print "not ok 1\n";
}

if(!$needed) {
  warn "You don't need nv() for accurate representation of 69659e-292\n\n";
}
elsif(!$ok) {
  warn "Perl sets an incorrect value for 69659e-292 - unfortunately so, too, does nv()\n\n";
}
else {
 warn " For accurate representation of 69659e-292 (and presumably many other values),\n you need something like nv()\n\n";
}
