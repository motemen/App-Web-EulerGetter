use strict;
use warnings;
use Test::More;

use_ok 'EulerGetter::Board';

my $b = new_ok 'EulerGetter::Board', [ 4 ];

# diag join ', ', $b->hex_at(1, 1)->siblings;
# diag join ', ', $b->hex_at(0, 0)->siblings;
# diag join ', ', $b->hex_at(0, 4)->siblings;
# diag join ', ', $b->hex_at(2, 2)->siblings;

for my $hh (@{ $b->hexes }) {
    diag "@$hh";
}

warn $b->hex_at(3, 0)->nexts;

done_testing;
