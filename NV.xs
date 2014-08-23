
#ifdef  __MINGW32__
#ifndef __USE_MINGW_ANSI_STDIO
#define __USE_MINGW_ANSI_STDIO 1
#endif
#endif

#define PERL_NO_GET_CONTEXT 1

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"


#include <stdlib.h>
#include <float.h>

#ifdef _MSC_VER
#ifndef strtold
#define strtold strtod
#endif
#endif

void nv(pTHX_ char * str) {
   dXSARGS;
   char * unparsed;
#ifdef NV_IS_LONG_DOUBLE
   long double num;
   num = strtold(str, &unparsed);
#else
   double num;
   num = strtod (str, &unparsed);
#endif

   ST(0) = sv_2mortal(newSVnv(num));
   if(GIMME == G_ARRAY) {
     EXTEND(SP, 1);
     if(unparsed)
       ST(1) = sv_2mortal(newSViv(strlen(unparsed)));
     else
       ST(1) = sv_2mortal(newSViv(0));
     XSRETURN(2);
   }
   XSRETURN(1);
}

SV * nv_type(pTHX) {
#ifdef NV_IS_LONG_DOUBLE
   return newSVpv("long double", 0);
#else
   return newSVpv("double", 0);

#endif
}

unsigned long mant_dig(void) {
#ifdef NV_IS_LONG_DOUBLE
   return LDBL_MANT_DIG;
#else
   return DBL_MANT_DIG;
#endif
}

int Isnan_ld (long double d) {
  if(d == d) return 0;
  return 1;
}

/********************************************************
   Code for _ld2binary and _ld_str2binary plagiarised from
   tests/tset_ld.c in the mpfr library source.
********************************************************/

void _ld2binary (pTHX_ SV * ld, long flag) {

  dXSARGS;
  long double d = (long double)SvNV(ld);
  long double e;
  int exp = 1;
  unsigned long int prec = 0;
  int returns = 0;

  sp = mark;

  if(Isnan_ld(d)) {
      XPUSHs(sv_2mortal(newSVpv("@NaN@", 0)));
      XPUSHs(sv_2mortal(newSViv(exp)));
      XPUSHs(sv_2mortal(newSViv(prec)));
      XSRETURN(3);
  }

  if (d < (long double) 0.0 || (d == (long double) 0.0 && (1.0 / (double) d < 0.0))) {
      XPUSHs(sv_2mortal(newSVpv("-", 0)));
      returns++;
      d = -d;
  }

  /* now d >= 0 */
  /* Use 2 differents tests for Inf, to avoid potential bugs
     in implementations. */
  if (Isnan_ld (d - d) || (d > 1 && d * 0.5 == d)) {
      XPUSHs(sv_2mortal(newSVpv("@Inf@", 0)));
      XPUSHs(sv_2mortal(newSViv(exp)));
      XPUSHs(sv_2mortal(newSViv(prec)));
      returns += 3;
      XSRETURN(returns);
  }

  if (d == (long double) 0.0) {
      XPUSHs(sv_2mortal(newSVpv("0.0", 0)));
      XPUSHs(sv_2mortal(newSViv(exp)));
      XPUSHs(sv_2mortal(newSViv(prec)));
      returns += 3;
      XSRETURN(returns);
  }

  /* now d > 0 */
  e = (long double) 1.0;
  while (e > d) {
      e = e * (long double) 0.5;
      exp --;
  }

  if(flag) printf ("1: e=%.36Le\n", e);

  /* now d >= e */
  while (d >= e + e) {
      e = e + e;
      exp ++;
  }

  if (flag) printf ("2: e=%.36Le\n", e);

  /* now e <= d < 2e */
  XPUSHs(sv_2mortal(newSVpv("0.", 0)));
  returns ++;

  if (flag) printf ("3: d=%.36Le e=%.36Le prec=%lu\n", d, e, prec);
  while (d > (long double) 0.0) {
      prec++;
      if(d >= e) {
        XPUSHs(sv_2mortal(newSVpv("1", 0)));
        returns ++;
        d = (long double) ((long double) d - (long double) e);
      }
      else {
        XPUSHs(sv_2mortal(newSVpv("0", 0)));
        returns ++;
      }
      e *= (long double) 0.5;
      if (flag) printf ("4: d=%.36Le e=%.36Le prec=%lu\n", d, e, prec);
  }

  XPUSHs(sv_2mortal(newSViv(exp)));
  XPUSHs(sv_2mortal(newSViv(prec)));
  returns += 2;
  XSRETURN(returns);
}

void _ld_str2binary (pTHX_ char * ld, long flag) {

  dXSARGS;
  long double d;
  long double e;
  int exp = 1;
  unsigned long int prec = 0;
  int returns = 0;

#ifdef NV_IS_LONG_DOUBLE
  d = strtold(ld, NULL);
#else
  d = (long double)strtod(ld, NULL);
#endif

  sp = mark;

  if(Isnan_ld(d)) {
      XPUSHs(sv_2mortal(newSVpv("@NaN@", 0)));
      XPUSHs(sv_2mortal(newSViv(exp)));
      XPUSHs(sv_2mortal(newSViv(prec)));
      XSRETURN(3);
  }

  if (d < (long double) 0.0 || (d == (long double) 0.0 && (1.0 / (double) d < 0.0))) {
      XPUSHs(sv_2mortal(newSVpv("-", 0)));
      returns++;
      d = -d;
  }

  /* now d >= 0 */
  /* Use 2 differents tests for Inf, to avoid potential bugs
     in implementations. */
  if (Isnan_ld (d - d) || (d > 1 && d * 0.5 == d)) {
      XPUSHs(sv_2mortal(newSVpv("@Inf@", 0)));
      XPUSHs(sv_2mortal(newSViv(exp)));
      XPUSHs(sv_2mortal(newSViv(prec)));
      returns += 3;
      XSRETURN(returns);
  }

  if (d == (long double) 0.0) {
      XPUSHs(sv_2mortal(newSVpv("0.0", 0)));
      XPUSHs(sv_2mortal(newSViv(exp)));
      XPUSHs(sv_2mortal(newSViv(prec)));
      returns += 3;
      XSRETURN(returns);
  }

  /* now d > 0 */
  e = (long double) 1.0;
  while (e > d) {
      e = e * (long double) 0.5;
      exp --;
  }

  if(flag) printf ("1: e=%.36Le\n", e);

  /* now d >= e */
  while (d >= e + e) {
      e = e + e;
      exp ++;
  }

  if (flag) printf ("2: e=%.36Le\n", e);

  /* now e <= d < 2e */
  XPUSHs(sv_2mortal(newSVpv("0.", 0)));
  returns ++;

  if (flag) printf ("3: d=%.36Le e=%.36Le prec=%lu\n", d, e, prec);
  while (d > (long double) 0.0) {
      prec++;
      if(d >= e) {
        XPUSHs(sv_2mortal(newSVpv("1", 0)));
        returns ++;
        d = (long double) ((long double) d - (long double) e);
      }
      else {
        XPUSHs(sv_2mortal(newSVpv("0", 0)));
        returns ++;
      }
      e *= (long double) 0.5;
      if (flag) printf ("4: d=%.36Le e=%.36Le prec=%lu\n", d, e, prec);
  }

  XPUSHs(sv_2mortal(newSViv(exp)));
  XPUSHs(sv_2mortal(newSViv(prec)));
  returns += 2;
  XSRETURN(returns);
}

SV * _bug_95e20(pTHX) {
#ifdef NV_IS_LONG_DOUBLE
  return newSVnv(95e20L);
#else
  return newSVnv(95e20);
#endif
}

SV * _bug_1175557635e10(pTHX) {
#ifdef NV_IS_LONG_DOUBLE
  return newSVnv(1175557635e10L);
#else
  return newSVnv(1175557635e10);
#endif
}


MODULE = Math::NV  PACKAGE = Math::NV

PROTOTYPES: DISABLE


void
nv (str)
	char *	str
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        nv(aTHX_ str);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
nv_type ()
CODE:
  RETVAL = nv_type (aTHX);
OUTPUT:  RETVAL


unsigned long
mant_dig ()


void
_ld2binary (ld, flag)
	SV *	ld
	long	flag
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _ld2binary(aTHX_ ld, flag);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
_ld_str2binary (ld, flag)
	char *	ld
	long	flag
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _ld_str2binary(aTHX_ ld, flag);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
_bug_95e20 ()
CODE:
  RETVAL = _bug_95e20 (aTHX);
OUTPUT:  RETVAL


SV *
_bug_1175557635e10 ()
CODE:
  RETVAL = _bug_1175557635e10 (aTHX);
OUTPUT:  RETVAL


