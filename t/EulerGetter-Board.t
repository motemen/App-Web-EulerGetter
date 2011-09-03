use strict;
use warnings;
use Test::More;

use_ok 'EulerGetter::Board';

my $b = EulerGetter::Board->new(3);

$b->hex_at(1, 2)->color('red');
is $b->hex_at(1, 2)->color, 'red';

is +EulerGetter::Board->from_hash($b->as_hash)->hex_at(1, 2)->color, 'red';

done_testing;
