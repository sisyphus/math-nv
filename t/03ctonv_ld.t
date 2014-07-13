use strict;
use warnings;

use Math::NV qw(:all);

my $tests = 4;

print "1..$tests\n";

if(mant_dig() != 64 && mant_dig() != 106) {
  warn "Skipping tests - they don't accommodate an NV\n that has a ", mant_dig(), "-bit mantissa\n\n";
  for(1 .. $tests) {print "ok $_\n";}
  exit 0;
}

my $needed = 0;
my $ok = 1;

my $correct1 = mant_dig() == 64 ? '0.100001011111000001000110100000101001001111110000111010110100111e-989'
                                : '0.1000010111110000010001101000001010010011111100001110101101001110001001011011101111111e-989';

my $correct2 = mant_dig() == 64 ? '0.100001111100010100001111010111100010100000101000011001e-953'
                                : '0.1000011111000101000011110101111000101000001010000110001111111111101010100101000000111011010110110010111011e-953';

my $str1 = '1e-298';
my $str2 = '69659e-292';

warn "Setting \$nv to $str1\n";

#################################
my $nv = $str1;

if($nv == nv($str1)) {
  warn"1. Perl and C agree that $str1 is $nv\n";
}
else {
  warn "1. Perl thinks that $str1 looks like ", float_bin($nv), "\n";
  warn "1. C    thinks that $str1 looks like ", float_bin(nv($str1)), "\n";
  $needed = 1;
}

if("$nv" eq $str1) {
  warn "2. \$nv stringifies to $str1 as expected\n";
}
else {
  warn "2. \$nv surprisingly stringifies to $nv\n";
  $needed = 1;
}

if(float_bin($nv) eq $correct1) {
  warn "3. $nv is ", float_bin($nv), " as expected\n";
}
else {
  warn "3. Perl sets $nv (wrongly) to ", float_bin($nv), "\n";
  $needed = 1;
}

if(float_bin(nv($str1)) ne $correct1) {
  warn "\$nv: $nv ", float_bin($nv), "\n";
  warn "nv(\$nv): ", nv("$nv"), " ", float_bin(nv("$nv")), "\n";
  $ok = 0;
}

#################################
#################################

$nv = $str2;

if($nv == nv($str2)) {
  warn"4. Perl and C agree that $str2 is $nv\n";
}
else {
  warn "4. Perl thinks that $str2 looks like ", float_bin($nv), "\n";
  warn "4. C    thinks that $str2 looks like ", float_bin(nv($str2)), "\n";
  $needed = 1;
}

if("$nv" eq $str2) {
  warn "5. \$nv stringifies to $str2 as expected\n";
}
else {
  warn "5. \$nv surprisingly stringifies to $nv\n";
  $needed = 1;
}

if(float_bin($nv) eq $correct2) {
  warn "6. $nv is ", float_bin($nv), " as expected\n";
}
else {
  warn "6. Perl sets $nv (wrongly) to ", float_bin($nv), "\n";
  $needed = 1;
}

if(float_bin(nv($str2)) ne $correct2) {
  warn "\$nv: $nv ", float_bin($nv), "\n";
  warn "nv(\$nv): ", nv("$nv"), " ", float_bin(nv("$nv")), "\n";
  $ok = 0;
}

#################################
#################################

if($correct1 eq str_bin($str1)) {print "ok 1\n"}
else {
 warn "Got:\n", str_bin($str1), "\nExpected:\n$correct1\n\n";
 print "not ok 1\n";
}

if($correct2 eq str_bin($str2)) {print "ok 2\n"}
else {
 warn "Got:\n", str_bin($str2), "\nExpected:\n$correct2\n\n";
 print "not ok 2\n";
}

if(float_bin(nv($str1)) eq $correct1) {print "ok 3\n"}
else {
  warn "Got:\n", float_bin(nv($str1)), "\nExpected:\n$correct1\n\n";
  print "not ok 3\n";
}


if(float_bin(nv($str2)) eq $correct2) {print "ok 4\n"}
else {
  warn "Got:\n", float_bin(nv($str2)), "\nExpected:\n$correct2\n\n";
  print "not ok 4\n";
}

#################################
#################################

if($ok) {
  my ($count, $t) = (0,0);
  warn "Looking for other discrepancies\n";
  for my $exp(10, 20, 30, 280 .. 300) {
    for my $digits(1..17) {
      $t++;
      my $nv = random_select($digits) . 'e' . "-$exp";
      #warn float_hex($nv), " ", float_hex(nv($nv)), "\n";
      if(float_bin($nv) ne float_bin(nv($nv))) {
        print "\$nv: $nv\n";
        print "perl:\n", float_bin($nv), "\nnv:\n", float_bin(nv($nv)), "\n\n";
        $count++;
      }
      else {print "\$nv: $nv ok\n\n";}
    }

  }
  warn "Found $count discrepancies in a further $t random(ish) tests\n";
}

#################################
#################################

if(!$needed) {
  warn "You don't need nv() for accurate representation of 1e-298 or 69659e-292\n\n";
}
elsif(!$ok) {
  warn "Perl sets an incorrect value for 1e-298 and/or 69659e-292 - unfortunately so, too, does nv()\n\n";
}
else {
 warn " For accurate representation of 1e-298 and/or 69659e-292 (and presumably many other values),\n you need something like nv()\n\n";
}

#################################
#################################

sub float_bin {
  my @in = ld2binary($_[0], 0);
  return $in[0] . 'e' . $in[1];
}

sub str_bin {
  my @in = ld_str2binary($_[0], 0);
  return $in[0] . 'e' . $in[1];
}


sub random_select {
  my $ret = '';
  for(1 .. $_[0]) {
    $ret .= int(rand(10));
  }
  return $ret;
}
