package EulerGetter::Game;
use strict;
use warnings;
use EulerGetter::Board;
use Class::Accessor::Lite
    new => 1,
    rw => [ 'board', 'turn' ];

use constant COLORS => [ 'red', 'blue' ];

sub current_color {
    my $self = shift;
    return COLORS->[ $self->turn % 2 ];
}

sub proceed {
    my $self = shift;
    $self->{turn}++;
}

1;
