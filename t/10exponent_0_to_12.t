# No tests to fail here - just output the result.

use strict;
use warnings;
use Math::NV qw(:all);
use Config;

print "1..1\n";

my($total_count, $discrepancies) = (0, 0);


for my $exp(0 .. 12) {
  for(1..1000) {
    $total_count++;
    my $rand = int(rand(10));
    my $str .=  "$rand" . '.' . random_select(14) . "e$exp";
    my $nv = $str;
    my $nv_correct = nv($str);
    if($nv_correct != $nv) {
      $discrepancies++;
    }
  }
}

warn "\nnvtype: $Config{nvtype}\n\$total_count: $total_count\n\$discrepancies: $discrepancies\n\n";

print "ok 1\n";

###################
###################
sub random_select {
  my $ret = '';
  for(1 .. $_[0]) {
    $ret .= int(rand(10));
  }
  return $ret;
}
