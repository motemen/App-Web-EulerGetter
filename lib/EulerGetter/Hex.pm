package EulerGetter::Hex;
use strict;
use warnings;
use overload '""' => \&stringify, fallback => 1;
use Scalar::Util qw(weaken);
use Class::Accessor::Lite
    new => 1,
    rw => [ 'x', 'y', 'board', 'color' ];

#  0 1
# 2 * 3
#  4 5

use constant SIBLING_DELTAS => (
    [ -1, -1 ],
    [  0, -1 ],
    [ -1,  0 ],
    [ +1,  0 ],
    [  0, +1 ],
    [ +1, +1 ],
);

sub siblings {
    my $self = shift;

    map {
        my ($dx, $dy) = @$_;
        $self->board->hex_at($self->x + $dx, $self->y + $dy);
    } SIBLING_DELTAS;
}

sub id {
    my $self = shift;
    return $self->y * $self->board->size + $self->x + 1;
}

sub stringify {
    my $self = shift;
    return sprintf '#%d <%d,%d>', $self->id, $self->x, $self->y;
}

1;
