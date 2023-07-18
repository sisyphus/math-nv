use strict;
use warnings;
use Math::NV qw(:all);

use Test::More;

for( -20, -21, -22, -23, -1.5, -0.5, 0.5, 1.5, 20, 21, 22, 23) {
  my $nv_prec = mant_dig();
  my $buff_size = int($nv_prec / 2);
  Math::MPFR::Rmpfr_set_default_prec($nv_prec);
  my $nv = 2 ** $_;
  my $op = Math::MPFR->new(2 ** $_);
  my $p_hex = sprintf "%a", $nv;
  my $buff = ' ' x $buff_size;
  Math::MPFR::Rmpfr_sprintf($buff, "%Ra", $op, $buff_size);

  cmp_ok($p_hex, 'eq', hex_alt($op, "%a"), "$_ %a: perl matches mpfr");
  cmp_ok($buff, 'eq',  hex_alt($nv, "%a"), "$_ %a: mpfr matches perl");
}

for( -200, -201, -202, -203, -3.5, -2.5, 2.5, 3.5, 200, 201, 202, 203) {
  my $nv_prec = mant_dig();
  my $buff_size = int($nv_prec / 2);
  Math::MPFR::Rmpfr_set_default_prec($nv_prec);
  my $nv = 2 ** $_;
  my $op = Math::MPFR->new(2 ** $_);
  my $p_hex = sprintf "%A", $nv;
  my $buff = ' ' x $buff_size;
  Math::MPFR::Rmpfr_sprintf($buff, "%RA", $op, $buff_size);

  cmp_ok($p_hex, 'eq', hex_alt($op, "%A"), "$_ %A: perl matches mpfr");
  cmp_ok($buff, 'eq',  hex_alt($nv, "%A"), "$_ %A: mpfr matches perl");
}

done_testing();
