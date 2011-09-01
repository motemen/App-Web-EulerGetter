use strict;
use warnings;
use Test::More;

use_ok 'EulerGetter::Board';

my $b = new_ok 'EulerGetter::Board', [ 4 ];

diag join ',', $b->hex_at(1, 1)->siblings;
diag join ',', $b->hex_at(0, 0)->siblings;
diag join ',', $b->hex_at(3, 0)->siblings;

warn $b->hex_at(3, 0);

done_testing;
