use strict;
use warnings;
use Test::More;

use_ok 'EulerGetter::Game';

{
    my $g = EulerGetter::Game->new(4);

    is $g->euler_score_of_color('red'), 0;
    is $g->euler_score_of_color('blue'), 0;

    $g->proceed_trun_with_hex(3, 0);
    is $g->euler_score_of_color('red'), 1;
    diag $g->board->dump_as_string;

    $g->proceed_trun_with_hex(0, 3);
    is $g->euler_score_of_color('blue'), 1;

    $g->proceed_trun_with_hex(4, 0);
    is $g->euler_score_of_color('red'), 1;

    $g->proceed_trun_with_hex(2, 3);
    is $g->euler_score_of_color('blue'), 2;

    $g->proceed_trun_with_hex(2, 4);
    is $g->euler_score_of_color('red'), 1;

    $g->proceed_trun_with_hex(1, 3);
    is $g->euler_score_of_color('blue'), 1;

    diag $g->board->dump_as_string;
}

{
    my $g = EulerGetter::Game->new(4);
    $g->proceed_trun_with_hex(4, 0);

    is $g->euler_score_of_color('red'), 1;
    diag $g->board->dump_as_string;
}

{
    my $g = EulerGetter::Game->new(4);
    $g->proceed_trun_with_hex(4, 0);
    $g->proceed_trun_with_hex(3, 0);
    $g->proceed_trun_with_hex(2, 2);
    $g->proceed_trun_with_hex(4, 1);
    is $g->euler_score_of_color('red'), 2;
    is $g->euler_score_of_color('blue'), 0;
    diag $g->board->dump_as_string;
}

done_testing;
