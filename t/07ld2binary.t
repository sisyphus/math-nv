use strict;
use warnings;
use POSIX;
use Math::NV qw(:all);

my $t = 6;
print "1..6\n";

my @s = ('1e-298', 1e-298, '1e+129', 1e+129, exp(1), log(10), '69659e-292', 69659e-292, '95e20',
          95e20, '1175557635e10', 1175557635e10, '80811924651145035e-20', 80811924651145035e-20,
         '26039550862e-20', 26039550862e-20, '918e-295', 918e-295, '91563373e-300', 91563373e-300,
         '897e-292', 897e-292,
         '-1e-298', -1e-298, '-1e+129', -1e+129, -exp(1), -log(10), '-69659e-292', -69659e-292, '-95e20',
          -95e20, '-1175557635e10', -1175557635e10, '-80811924651145035e-20', -80811924651145035e-20,
         '-26039550862e-20', -26039550862e-20, '-918e-295', -918e-295, '-91563373e-300', -91563373e-300,
         '-897e-292', -897e-292,);

if(nv_type() eq 'double') {
  warn "\nTests (5 & 6) will be done against POSIX::strtod\n";
  *alias_sub = \&POSIX::strtod;
}
elsif($] > 5.021003) {
  warn "\nTests (5 & 6) will be done against POSIX::strtold\n";
  *alias_sub = \&POSIX::strtold;
}
else {
  # Test that nv($_) == nv($_) ... assume they will pass as there should be no nans.
  warn "\nNot doing tests (5 & 6) against POSIX\n";
  *alias_sub = \&alias_fallback;
}

my @ok = (1) x $t;

for(@s) {
  my @bin1 = ld2binary($_, 0);
  my @bin2 = ld2binary("$_", 0);
  my @bin3 = ld_str2binary($_, 0);
  my @bin4 = ld_str2binary("$_", 0);

  if(bin2val(@bin1) != $_) {
    warn "1: discrepancy wrt $_\n";
    $ok[0] = 0;
  }

    if(bin2val(@bin2) != "$_") {
    warn "2: discrepancy wrt $_\n";
    $ok[1] = 0;
 }

  if(bin2val(@bin3) != nv($_)) {
    warn "3: discrepancy wrt $_\n";
    $ok[2] = 0;
  }

    if(bin2val(@bin4) != nv("$_")) {
    warn "4: discrepancy wrt $_\n";
    $ok[3] = 0;
  }

  if(alias_sub($_) != nv($_)) {
    warn "5: discrepancy wrt $_\n";
    $ok[4] = 0;
  }

    if(alias_sub("$_") != nv("$_")) {
    warn "6: discrepancy wrt $_\n";
    $ok[5] = 0;
  }
}

for(1..$t) {
  if($ok[$_ - 1]) {print "ok $_\n"}
  else {print "not ok $_\n"}
}

sub alias_fallback {return nv($_[0])}
