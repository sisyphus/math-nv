## This file generated by InlineX::C2XS (version 0.22) using Inline::C (version 0.53)
package Math::NV;
use warnings;
use strict;

require Exporter;
*import = \&Exporter::import;
require DynaLoader;

$Math::NV::VERSION = '0.06';

DynaLoader::bootstrap Math::NV $Math::NV::VERSION;

@Math::NV::EXPORT = ();
@Math::NV::EXPORT_OK = qw(
    nv nv_type mant_dig ld2binary ld_str2binary is_eq mant2binary mant_str2binary
    bin2val Cprintf Csprintf
    );

%Math::NV::EXPORT_TAGS = (all => [qw(
    nv nv_type mant_dig ld2binary ld_str2binary is_eq mant2binary mant_str2binary
    bin2val Cprintf Csprintf
    )]);

sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

sub ld2binary {
  my @ret = _ld2binary($_[0], $_[1]);
  my $prec = pop(@ret);
  my $exp = pop(@ret);
  my $mantissa = join '', @ret;
  return ($mantissa, $exp, $prec);
}

sub ld_str2binary {
  my @ret = _ld_str2binary($_[0], $_[1]);
  my $prec = pop(@ret);
  my $exp = pop(@ret);
  my $mantissa = join '', @ret;
  return ($mantissa, $exp, $prec);
}

sub bin2val {
  my($mantissa, $exp, $prec) = (shift, shift, shift);
  my $sign = $mantissa =~ /^\-/ ? '-' : '';
  # Remove everything upto and including the radix point
  # as it now contains no useful information.
  $mantissa =~ s/.+\.//;
  # For our purposes the values $prec and $exp need
  # to be reduced by 1.
  $exp--;

  # Perl bugs make the following (commented out) code unreliable,
  # so we now hand the calculations over to C.
  # (And there's no need to decrement $prec.)
  #$prec--;
  #for(0..$prec) {
  #  if(substr($mantissa, $_, 1)) {$val += 2**$exp}
  #  $exp--;
  #}
  my @mantissa = split //, $mantissa;
  my $val = _bin2val($prec, $exp, \@mantissa);
  $sign eq '-' ? return -$val : return $val;
}

sub is_eq {
  my $nv = $_[0];
  return 1 if $nv == nv($_[0]);
  return 0;
}

sub mant2binary {
    my $prec = mant_dig();
    my $format = $prec == 53 ? "F<" : "D<";
    return scalar reverse unpack "b$prec", pack $format, $_[0];
}

sub mant_str2binary {
    my $prec = mant_dig();
    my $format = $prec == 53 ? "F<" : "D<";
    return scalar reverse unpack "b$prec", pack $format, "$_[0]";
}

1;

__END__

=head1 NAME

Math::NV - assign correct value to perl's NV

=head1 DESCRIPTION

   use Math::NV qw(:all);
   my $nv = nv('1e-298'); # ie the number 10 ** -298
   # or, in list context:
   my($nv, $iv) = nv('1e-298');

   The above snippet will assign a correct value for 1e-298 to $nv.
   Doing simply "$nv = 1e-298;" may *not* do that. (The test suite
   specifically checks and reports whether 1e-298 can correctly be
   assigned directly to a perl scalar. It also checks some other
   values).
   $iv is set to the number of characters in the input string that
   were unparsed.

   The nv() function assigns the value at the C (XS) level using
   either the C function strtod() or strtold() - whichever is
   appropriate for your perl's configuration.

   Obviously, we are therefore relying upon absence of bugs in the
   way your compiler/libc assigns strings to floats. (Hopefully, if
   such bugs are present, this will become evident in the form of
   failures in the module's test suite.)

   NOTE:
    For an NV $nv, it's not guaranteed that nv($nv) and nv("$nv")
    will be equivalent. For example, on many of my 64-bit MS Win
    builds of perl, a print() of nv('1e-298') will output 1e-298,
    whereas a print() of nv(1e-298) outputs 9.99999999999999e-299.


=head1 FUNCTIONS

   $nv = nv($str);        # scalar context
   ($nv, $iv) = nv($str); # list context

    On perls whose NV is a C "double", assigns to $nv the value that
    the C standard library function strtod($str) assigns.
    On perls whose NV is a C "long double", assigns to $nv the value
    that the C standard library function strtold($str) assigns.
    In list context, also returns the number of characters that were
    unparsed (ignored).

   $nv_type = nv_type();

    Returns either "double" or "long double", depending upon the way
    perl has been configured.
    The expectation is that it returns the same as $Config{nvtype}.
    (Please file a bug report if you find otherwise.)

   $bool = is_eq($str);
     Returns true if the value perl assigns from the string $str is
     equal to the value C assigns from the same string.
     Else returns false.

   $digits = mant_dig();

    Returns the number of bits the NV mantissa contains. This is
    normally 53 if nv_type() is double - otherwise usually (but by no
    means always) 64.
    It returns the value of the C macro DBL_MANT_DIG or LDBL_MANT_DIG,
    depending upon whichever is appropriate for perl's configuration.

   ($mantissa, $exponent, $precision) = ld2binary($nv, $flag);

    Uses code taken from tests/tset_ld.c in the mpfr library source
    and returns a base 2 representation of the value contained in the
    NV $nv - irrespective of whether the NV type ($Config{nvtype}) is
    double or long double.
    If $flag is true, it also prints out additional information during
    calculation.
    $mantissa is the mantissa (significand).
    $exponent is the exponent.
    $precision is the precision (in bits) of the mantissa - trailing
    zero bits are not counted.


   ($mantissa, $exponent, $precision) = ld_str2binary($str, $flag);

    Uses code taken from tests/tset_ld.c in the mpfr library source
    and returns a base 2 representation of the value of the NV
    represented by the string $str - irrespective of whether the NV
    type ($Config{nvtype}) is double or long double.
    If $flag is true, it also prints out additional information during
    calculation.
    $mantissa is the mantissa (significand).
    $exponent is the exponent.
    $precision is the precision (in bits) of the mantissa - trailing
    zero bits are not counted.

   $nv = bin2val($mantissa, $exponent, $precision);

    Takes the return values of ld_str2binary() or ld2binary() and
    returns the original NV. (Probably doesn't work if the original
    NV is an inf or a nan.)

   $mantissa = mant2binary($nv);

    Returns a base 2 representation of the mantissa of $nv using
    perl's unpack/pack functions.

   $mantissa = mant_str2binary($str);

    Returns a base 2 representation of the mantissa of the value
    represented by $str. (Also uses perl's unpack/pack functions.)

   Cprintf($fmt, $nv);
    Uses C's printf() function to format the NV $nv, according to the
    formatting specified by the string $fmt.

   $string = Csprintf($fmt, $nv, $buffer_size);
    Uses C's sprintf() function to format the NV $nv, according to the
    formatting specified by the string $fmt - and returns the result to
    $string. It's the responsibility of the caller to ensure that
    $buffer_size specifies a large enough (at least) number of characters
    to accommodate C's sprintf formatting of $nv.

=head1 LICENSE

   This program is free software; you may redistribute it and/or modify
   it under the same terms as Perl itself.
   Copyright 2013-14 Sisyphus


=head1 AUTHOR

   Sisyphus <sisyphus at(@) cpan dot (.) org>

=cut
