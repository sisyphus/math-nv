use strict;
use warnings;
use Math::NV qw(:all);

my $md = mant_dig();

my $t = 2;
print "1..$t\n";

if($md == 106) {
  warn "\nSkipping all tests - mant2binary() not yet ported to this architecture\n";
  print "ok $_\n" for 1..$t;
  exit 0;
}

eval{require 5.010;};

if($@) {
  warn "Skipping all tests - perl-5.10 or later needed; have only $]\n";
  print "ok $_\n" for 1..$t;
  exit 0;
}

if($md != 53 && $md != 64 && $md != 106 && $md != 113) {
  warn "Skip - tests don't accommodate a ${md}-bit mantissa\n";
  for(1 .. $t) {print "ok $_\n"}
  exit 0;
}

my %v = (
 53  => '11111111100110101101110100111100000011111111110011110',
 64  => '1111111110011010110111010011110000001111111111001110111011100000',
 106 => '1111111110011010110111010011110000001111111111001110111011100000001011001100100001000101110100011111110001',
 113 => '11111111100110101101110100111100000011111111110011101110111000000010110011001000010001011101000111111100001111000',
);

my $str = '7.987654321012';
my $nv = $str * 1.0;

my $binnv =  mant2binary($nv);
my $binstr = mant_str2binary($str);

if($binnv eq $v{$md}) {print "ok 1\n"}
else {
  warn "\$binnv:\n$binnv\n\$v{$md}:\n$v{$md}\n\n";
  print "not ok 1\n";
}

if($binstr eq $v{$md}) {print "ok 2\n"}
else {
  warn "\$binstr:\n$binstr\n\$v{$md}:\n$v{$md}\n\n";
  print "not ok 2\n";
}






