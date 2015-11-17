
# NV.pm will always load Math::MPFR iff it's available.
# Math::NV::no_mpfr will be set to 0 iff Math::MPFR loaded successfully.
# Otherwise $Math::NV::no_mpfr will be set to the error message that the
# attempt to load Math::MPFR produced.

use strict;
use warnings;
use Math::NV qw(:all);

if($Math::NV::no_mpfr) {
  print "1..1\n";
  warn "\nMath::MPFR not available - skipping all other tests\n";
}
else {
  print "1..14\n";

  my $val = nv_mpfr('1e+127', 106);

  if(lc((@$val)[2]) eq "5a4d8ba7f519c84f") {print "ok 1\n"}
  else {
    warn "expected \"5a4d8ba7f519c84f\", got ", lc((@$val)[2]), "\n";
    print "not ok 1\n";
  }

  if(lc((@$val)[3]) eq "56e7fd1f28f89c56") {print "ok 2\n"}
  else {
    warn "expected \"56e7fd1f28f89c56\", got ", lc((@$val)[3]), "\n";
    print "not ok 2\n";
  }


  $val = nv_mpfr('1e+129', 106);


  if(lc((@$val)[2]) eq "5ab7151b377c247e") {print "ok 3\n"}
  else {
    warn "expected \"5ab7151b377c247e\", got ", lc((@$val)[2]), "\n";
    print "not ok 3\n";
  }

  if(lc((@$val)[3]) eq "5707b80b0047445d") {print "ok 4\n"}
  else {
    warn "expected \"5707b80b0047445d\", got ", lc((@$val)[3]), "\n";
    print "not ok 4\n";
  }

  eval {$val = nv_mpfr('1.3', 1000);};

  if($@ =~ /^Specified bits/) {print "ok 5\n"}
  else {
    warn "\n\$\@: $@";
    print "not ok 5\n";
  }

  eval {$val = nv_mpfr('1.3', 10);};

  if($@ =~ /^Unrecognized value for bits/) {print "ok 6\n"}
  else {
    warn "\n\$\@: $@\n";
    print "not ok 6\n";
  }

#####################################

  if(mant_dig == 106) {
    warn "\nskipping tests 7-10 for doubledouble\n";
    print "ok 7\nok 8\nok 9\nok 10\n";
  }
  else {
    $val =     nv_mpfr('2.3', mant_dig());
    my $val2 = nv_mpfr('2.3');

    if((@$val)[0] == (@$val2)[0]) {print "ok 7\n"}
    else {
      warn "\nexpected (@$val)[0], got (@$val2)[0]\n";
      print "not ok 7\n";
    }

    if((@$val)[1] eq (@$val2)[1]) {print "ok 8\n"}
    else {
      warn "\nexpected (@$val)[1], got (@$val2)[1]\n";
      print "not ok 8\n";
    }

    if((@$val)[0] == 2.3) {print "ok 9\n"}
    else {
      warn "\nexpected 2.3, got (@$val)[0]\n";
      print "not ok 9\n";
    }

    my $expected = lc(scalar(reverse(unpack("h*", pack("F<", 2.3)))));
    if(lc((@$val)[1]) eq $expected) {print "ok 10\n"}
    else {
      warn "\nexpected $expected, got ", lc((@$val)[1]), "\n";
      print "not ok 10\n";
    }

  }

  $val = nv_mpfr('1e+127', 53);

  if(lc((@$val)[1]) eq "5a4d8ba7f519c84f") {print "ok 11\n"}
  else {
    warn "expected \"5a4d8ba7f519c84f\", got ", lc((@$val)[1]), "\n";
    print "not ok 11\n";
  }


#####################################

  if(mant_dig() >= 64) {

    if(mant_dig() == 106) {
      warn "\nSkipping test 12 on double-double platform\n";
      print "ok 12\n";
    }

    elsif(mant_dig() == 113) {
      warn "\nSkipping test 12 on __float128 platform\n";
      print "ok 12\n";
    }

    else {
      $val = nv_mpfr('1e+127', 64);

      my $expected = lc((@$val)[1]);
      $expected =~ s/^(0+)//;

      if($expected eq "41a4ec5d3fa8ce427b00") {print "ok 12\n"}
      else {
        warn "expected \"41a4ec5d3fa8ce427b00\", got ", $expected, "\n";
        print "not ok 12\n";
      }
    }

  }
  else {
    eval {$val = nv_mpfr('1e+127', 64);};
    if($@ =~ /^Specified bits/) {print "ok 12\n"}
    else {
      warn "\n\$\@: $@\n";
      print "not ok 12\n";
    }

  }

######################################

  if(mant_dig() == 113) {

    $val = nv_mpfr('1e+127', 113);

    if(lc((@$val)[1]) eq "41a4d8ba7f519c84f5ff47ca3e27156a") {print "ok 13\n"}
    else {
      warn "expected \"41a4d8ba7f519c84f5ff47ca3e27156a\", got ", lc((@$val)[1]), "\n";
      print "not ok 13\n";
    }

  }
  else {
    eval {$val = nv_mpfr('1e+127', 113);};
    if($@ =~ /^Specified bits/) {print "ok 13\n"}
    else {
      warn "\n\$\@: $@\n";
      print "not ok 13\n";
    }

  }

######################################

  $Math::NV::no_mpfr = 1;

  eval {nv_mpfr(123, 1000);};

  if($@ =~ /^In nv_mpfr\(\): 1/) {print "ok 14\n"}
  else {
    warn "\n\$\@: $@\n";
    print "not ok 14\n";
  }

  $Math::NV::no_mpfr = 0;

}
