use strict;
use warnings;
use Config;
use Math::NV qw(:all);

my $tests = 2;

print "1..$tests\n";

if(mant_dig() == 106) {
  warn "Skipping tests - they don't accommodate an NV that has a 106-bit mantissa\n";
  for(1 .. $tests) {print "ok $_\n";}
  exit 0;
}

require Data::Float; Data::Float->import('float_hex');

my $nvtype = nv_type();

die "NV is $Config{nvtype}, but Math::NV thinks it is $nvtype"
  if $nvtype ne $Config{nvtype};

my $needed = 0;
my $ok = 1;

warn "Setting \$nv to 1e-298\n";

my $nv = '1e-298';
my $correct = nv_type() eq 'double' ? '+0x1.0be08d0527e1dp-990'
                                    : $nvtype eq 'long double' ? '+0x1.0be08d0527e1d69cp-990'
                                                               : '+0x1.0be08d0527e1d69c4b77eac0118bp-990';

if($nv == nv('1e-298')) {
  warn"1. Perl and C agree that 1e-298 is $nv\n";
}
else {
  warn "1. Perl thinks that 1e-298 looks like ", float_hex($nv), "\n";
  warn "1. C    thinks that 1e-298 looks like ", float_hex(scalar nv('1e-298')), "\n";
  $needed = 1;
}

if("$nv" eq '1e-298') {
  warn "2. \$nv stringifies to 1e-298 as expected\n";
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

if(float_hex(scalar nv("1e-298")) eq $correct) {print "ok 1\n"}
else {
  warn "\$nv: $nv ", float_hex($nv), "\n";
  warn "nv(\$nv): ", nv("$nv"), " ", float_hex(nv("$nv")), "\n";
  $ok = 0;
  print "not ok 1\n";
}

if(nv_type() eq $Config{nvtype}) {print "ok 2\n"}
else {
  warn "nv_type(): ", nv_type(), "\nnvtype: $Config{nvtype}\n";
  print "not ok 2\n";
}


if($ok) {
  my ($count, $tests) = (0,0);
  warn "Looking for other discrepancies\n";
  for my $exp(10, 20, 30, 280 .. 300) {
    for my $digits(1..15) {
      $tests++;
      my $nv = random_select($digits) . 'e' . "-$exp";
      if(float_hex($nv) ne float_hex(scalar nv($nv))) {
        print "\$nv: $nv\n";
        print "perl: ", float_hex($nv), " nv: ", float_hex(scalar nv($nv)), "\n\n";
        $count++;
      }
      else {print "\$nv: $nv ok\n\n";}
    }

  }
  warn "Found $count discrepancies in a further $tests random(ish) tests\n";
}

if(!$needed) {
  warn "You don't need nv() for accurate representation of 1e-298\n\n";
}
elsif(!$ok) {
  warn "Perl sets an incorrect value for 1e-298 - unfortunately so, too, does nv()\n\n";
}
else {
 warn " For accurate representation of 1e-298 (and presumably many other values),\n you need something like nv()\n\n";
}

sub random_select {
  my $ret = '';
  for(1 .. $_[0]) {
    $ret .= int(rand(10));
  }
  return $ret;
}

#69659e-292
