use strict;
use warnings;
use POSIX;
use Math::NV qw(:all);

my $t = 6;
print "1..6\n";

my $md = mant_dig();

if($md != 106) {
  warn "\nSkipping all tests - Data::Float::DoubleDouble doesn't support this architecture\n";
  print "ok $_\n" for 1..$t;
  exit 0;
}

eval{require Data::Float::DoubleDouble;
Data::Float::DoubleDouble->import('float_H');};

if($@) {
  warn "\nSkipping all tests - Data::Float::DoubleDouble could not be loaded:\n $@\n";
  print "ok $_\n" for 1..$t;
  exit 0;
}

$main::dp = POSIX::localeconv->{decimal_point};
warn "POSIX::localeconv->{decimal_point} is $main::dp\n";

my @s = ('1e-298', 1e-298, '1e+129', 1e+129, exp(1), log(10), '69659e-292', 69659e-292, '95e20',
          95e20, '1175557635e10', 1175557635e10, '80811924651145035e-20', 80811924651145035e-20,
         '26039550862e-20', 26039550862e-20, '918e-295', 918e-295, '91563373e-300', 91563373e-300,
         '897e-292', 897e-292,
         '-1e-298', -1e-298, '-1e+129', -1e+129, -exp(1), -log(10), '-69659e-292', -69659e-292, '-95e20',
          -95e20, '-1175557635e10', -1175557635e10, '-80811924651145035e-20', -80811924651145035e-20,
         '-26039550862e-20', -26039550862e-20, '-918e-295', -918e-295, '-91563373e-300', -91563373e-300,
         '-897e-292', -897e-292,);


if($] > 5.021003 && nv_type() eq 'long double') {
  warn "\nTests (5 & 6) will be done against POSIX::strtold\n";
  $main::which = 2;
  #*alias_sub = \&POSIX::strtold;
}
else {
  # Test that nv($_) == nv($_) ... assume they will pass as there should be no nans.
  warn "\nNot doing tests (5 & 6) against POSIX\n";
  $main::which = 3;
  #*alias_sub = \&alias_fallback;
}

my @ok = (1) x $t;

for(my $i = 0; $i < @s; $i++) {
  my $numstr = fix_decimal_point("$s[$i]"); # Some locale settings seem to screw up the decimal point.
  my @bin1 = ld2binary($s[$i]);
  my @bin2 = ld2binary($numstr);
  my @bin3 = ld_str2binary($s[$i]);
  my @bin4 = ld_str2binary($numstr);

  if(bin2val(@bin1) != $s[$i]) {
    warn "1 ($i): discrepancy wrt $s[$i]\n";
    for(@bin1) {warn " $_\n"}
    warn " ", float_H(bin2val(@bin1)), "\n";
    warn " ", float_H($s[$i]), "\n\n";
    $ok[0] = 0;
  }

    if(bin2val(@bin2) != $numstr) {
    warn "2 ($i): discrepancy wrt $s[$i]\n";
    for(@bin2) {warn " $_\n"}
    warn " ", float_H(bin2val(@bin2)), "\n";
    warn " ", float_H($numstr), "\n\n";
    $ok[1] = 0;
 }

  if(bin2val(@bin3) != scalar nv($s[$i])) {
    warn "3 ($i): discrepancy wrt $s[$i]\n";
    for(@bin3) {warn " $_\n"}
    warn " ", float_H(bin2val(@bin3)), "\n";
    warn " ", float_H(nv($s[$i])), "\n\n";
    $ok[2] = 0;
  }

    if(bin2val(@bin4) != scalar nv($numstr)) {
    warn "4 ($i): discrepancy wrt $s[$i]\n";
    for(@bin4) {warn " $_\n"}
    warn " ", float_H(bin2val(@bin4)), "\n";
    warn " ", float_H(nv($numstr)), "\n\n";
    $ok[3] = 0;
  }

  if(alias_sub($s[$i]) != scalar nv($s[$i])) {
    warn "5 ($i): discrepancy wrt $s[$i]\n";
    warn " ", float_H(alias_sub($s[$i])), " (alias_sub)\n";
    warn " ", float_H(nv($s[$i])), " (nv)\n\n";
    $ok[4] = 0;
  }

    if(alias_sub("$s[$i]") != scalar nv("$s[$i]")) {
    warn "6 ($i): discrepancy wrt $s[$i]\n";
    warn " ", float_H(alias_sub("$s[$i]")), " (alias_sub)\n";
    warn " ", float_H(nv("$s[$i]")), " (nv)\n\n";
    $ok[5] = 0;
  }
}

for(1..$t) {
  if($ok[$_ - 1]) {print "ok $_\n"}
  else {print "not ok $_\n"}
}

sub alias_sub {
  if($main::which == 1) {
    my $numstr = shift;
    $numstr =~ s/\./$main::dp/; # Use localeconv->{decimal_point}
    return scalar POSIX::strtod($numstr);
  }
  elsif($main::which == 2) {
    my $numstr = shift;
    $numstr =~ s/\./$main::dp/;
    return scalar POSIX::strtold($numstr);
  }
  else {
    return scalar nv($_[0]);
  }
}

sub fix_decimal_point {
  my $numstr = $_[0];
  return $numstr if Math::NV::_looks_like_number($numstr);
  $numstr =~ s/\./,/;
  return $numstr if Math::NV::_looks_like_number($numstr);
  $numstr =~ s/,/./;
  return $numstr if Math::NV::_looks_like_number($numstr);
  return $_[0]; # give up
}



