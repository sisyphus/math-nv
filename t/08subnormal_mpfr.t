
# NV.pm will always load Math::MPFR iff it's available.
# Math::NV::no_mpfr will be set to 0 iff Math::MPFR loaded successfully.
# Otherwise $Math::NV::no_mpfr will be set to the error message that the
# attempt to load Math::MPFR produced.

# Smallest normal __float128 is:
# 3.3621031431120935062626778173217526e-4932

# Smallest normal (extended precision) long double is:
# 3.36210314311209350626e-4932

# Smallest normal double is:
# 2.2250738585072014e-308

use strict;
use warnings;
use Math::NV qw(:all);
use Config;

my $t = 7;

print "1..$t\n";

my $ok = 1;
my $exponent;

if($Math::NV::no_mpfr) {
  warn "\nMath::MPFR not available - skipping all other tests\n";
  print "ok $_\n" for 1..$t;
  exit 0;
}

warn "\nThese tests can take a few moments to complete\n";


my $check = Math::MPFR::Rmpfr_init2(300);

$exponent = $Config{nvtype} eq 'double' ? '-308' : '-4932';

for my $count(1 .. 400000) {

  my $str = sprintf "%06d", $count;
  substr($str, 1, 0, '.');
  $str .= "e$exponent";

  Math::MPFR::Rmpfr_set_str($check, $str, 10, 0);

  my $nv = Math::MPFR::Rmpfr_get_NV($check, 0);

  my $out1 = scalar(reverse(unpack("h*", pack("F<", $nv))));
  #if(mant_dig() == 64) {
  #  $out1 = substr($out1, length($out1) - 20, 20);
  #}
  my $out2 = nv_mpfr($str);

  unless($out1 eq $out2) {
    warn "For $str:\n $out1 ne $out2\n";
    if($] >= '5.022') {
      warn "The former is: ", sprintf("%a\n", $nv), sprintf("%.16e\n", $nv);
      warn "The latter is: ", sprintf "%a\n", unpack("F<", pack "h*", scalar reverse $out2);
    }
    $ok = 0;
    last;
  }

}

$Math::NV::no_warn = 2;

if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}

$ok = 1;

for my $count(1 .. 400000) {

  my $str = sprintf "%06d", $count;
  substr($str, 1, 0, '.');
  $str .= "e$exponent";

  my $str_copy = $str;
  my $perl_nv = $str_copy + 0;

  my $out = unpack("F<", pack "h*", scalar reverse nv_mpfr($str));

  if($out == $perl_nv && !is_eq_mpfr($str)) {
    warn "For $str:\nperl and nv_mpfr() agree, but is_eq_mpfr($str) returns false\n";
    if($] >= '5.022') {
      warn "Perl says that $str evaluates to: ", sprintf "%a\n", $perl_nv;
      warn "nv_mpfr() says that $str evaluates to: ", sprintf "%a\n", $out;
    }
    $ok = 0;
    last;
  }

  if($out != $perl_nv  && is_eq_mpfr($str)) {
    warn "For $str:\nperl and nv_mpfr() disagree, but is_eq_mpfr($str) returns true\n";
    if($] >= '5.022') {
      warn "Perl says that $str evaluates to: ", sprintf "%a\n", $perl_nv;
      warn "nv_mpfr() says that $str evaluates to: ", sprintf "%a\n", $out;
    }
    $ok = 0;
    last;
  }

}

if($ok) {print "ok 2\n"}
else {print "not ok 2\n"}

$ok = 1;

for my $count(1 .. 222507) {

  my $str = sprintf "%06d", $count;
  substr($str, 1, 0, '.');
  $str .= "e-308";

  my $out1 = nv_mpfr($str, 53);
  my $out2 = nv_mpfr($str, 106);

  my @out = @$out2;

  if($out1 ne $out[0]) {
    warn "$out1 ne $out[0]\n";
    $ok = 0;
    last;
  }

  my $lsd = unpack("d<", pack "h*", scalar reverse $out[1]);

  unless($lsd == 0) {
    warn "\n$str: lsd ($out[1]) is not 0\n";
    $ok = 0;
    last;
  }
}

if($ok) {print "ok 3\n"}
else {print "not ok 3\n"}

$ok = 1;

eval{Math::MPFR::_dd_bytes('1e-2', 106)};

if(!$@) {
  for my $count(1 .. 400000) {

    my $str = sprintf "%06d", $count;
    substr($str, 1, 0, '.');
    $str .= "e-308";

    my $out_a = nv_mpfr($str, 106);
    my $out_b = join '', Math::MPFR::_dd_bytes($str, 106);

    my @out1 = @$out_a;
    my @out2 = (substr($out_b, 0, 16), substr($out_b, 16, 16));

    if($out1[0] ne $out2[0]) {
      warn "msd: $out1[0] ne $out2[0]\n";
      $ok = 0;
      last;
    }

    if($out1[1] ne $out2[1]) {
      warn "lsd: $out1[1] ne $out2[1]\n";
      $ok = 0;
      last;
    }
  }

  if($ok) {print "ok 4\n"}
  else {print "not ok 4\n"}
}
else {
  warn "\n skipping test 4:\n\$\@:\n$@\n";
  print "ok 4\n";
}


if($Math::MPFR::VERSION < 4.02) {
  warn "\nSkipping remaining tests.\nThey require Math-MPFR-4.02 and $Math::MPFR::VERSION is installed\n";
  print "ok $_\n" for 5..$t;
  exit 0;
}

$ok = 1;

$Math::NV::no_warn = 0;

eval{Math::MPFR::_d_bytes('1e-2', 53)};

if(!$@) {
  for my $count(1 .. 400000) {

    my $str = sprintf "%06d", $count;
    substr($str, 1, 0, '.');
    $str .= "e-308";

    my $out1 = nv_mpfr($str, 53);
    my $out2 = join '', Math::MPFR::_d_bytes($str, 53);

    if($out1 ne $out2) {
      warn "$out1 ne $out2\n";
      $ok = 0;
      last;
    }
  }

  if($ok) {print "ok 5\n"}
  else {print "not ok 5\n"}
}
else {
  warn "\n skipping test 5:\n\$\@:\n$@\n";
  print "ok 5\n";
}

$ok = 1;

eval{Math::MPFR::_ld_bytes('1e-2', Math::MPFR::LDBL_MANT_DIG)};

if(!$@) {
  for my $count(1 .. 400000) {

    my $str = sprintf "%06d", $count;
    substr($str, 1, 0, '.');
    $str .= "e-4932";

    my $out1 = nv_mpfr($str, Math::MPFR::LDBL_MANT_DIG);
    my $out2 = join '', Math::MPFR::_ld_bytes($str, Math::MPFR::LDBL_MANT_DIG);

    if($out1 ne $out2 && $out1 ne ('0000'. $out2) && $out1 ne ('000000000000'. $out2)) {
      warn "$out1 ne $out2\n";
      $ok = 0;
      last;
    }
  }

  if($ok) {print "ok 6\n"}
  else {print "not ok 6\n"}
}
else {
  warn "\n skipping test 6:\n\$\@:\n$@\n";
  print "ok 6\n";
}

$ok = 1;

eval{Math::MPFR::_f128_bytes('1e-2', 113)};

if(!$@) {
  for my $count(1 .. 400000) {

    my $str = sprintf "%06d", $count;
    substr($str, 1, 0, '.');
    $str .= "e-4932";

    my $out1 = nv_mpfr($str, 113);
    my $out2 = join '', Math::MPFR::_f128_bytes($str, 113);

    if($out1 ne $out2) {
      warn "$out1 ne $out2\n";
      $ok = 0;
      last;
    }
  }

  if($ok) {print "ok 7\n"}
  else {print "not ok 7\n"}
}
else {
  warn "\n skipping test 7:\n\$\@:\n$@\n";
  print "ok 7\n";
}

$ok = 1;

