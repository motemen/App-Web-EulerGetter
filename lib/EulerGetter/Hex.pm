package EulerGetter::Hex;
use strict;
use warnings;
use overload '""' => \&stringify, fallback => 1;
use Scalar::Util qw(weaken);
use Class::Accessor::Lite
    new => 1,
    rw => [ 'x', 'y', 'board', 'color' ];

#  0 1     0 1
# 5 * 2 -> 5 * 2
#  4 3       4 3

use constant SIBLING_DELTAS => [
    [ -1, -1 ],
    [  0, -1 ],
    [ +1,  0 ],
    [ +1, +1 ],
    [  0, +1 ],
    [ -1,  0 ],
];

use constant NEXT_DELTAS => [
    [ +1,  0 ],
    [ +1, +1 ],
    [  0, +1 ],
];

sub siblings {
    my $self = shift;
    return map { $_->_siblings } $self->board->hexes_of_id($self->id);
}

sub _siblings {
    my $self = shift;

    return grep { $_ } map {
        my ($dx, $dy) = @$_;
        $self->board->hex_at_dir(
            $self->x, $self->y,
            $dx, $dy
        );
    } @{+SIBLING_DELTAS};
}

sub nexts {
    my $self = shift;

    return grep { $_ } map {
        my ($dx, $dy) = @$_;
        $self->board->hex_at_dir(
            $self->x, $self->y,
            $dx, $dy
        );
    } @{+NEXT_DELTAS};
}

sub id {
    my $self = shift;
    # return $self->y * $self->board->size + $self->x + 1;
    return $self->canonical_y * $self->board->size + $self->canonical_x + 1;
}

sub canonical_x {
    my $self = shift;
    return 0 if $self->x == $self->board->size;
    return $self->board->size - $self->x if $self->y == $self->board->size && $self->x != 0;
    return $self->x;
}

sub canonical_y {
    my $self = shift;
    return $self->board->size - $self->y if $self->x == $self->board->size;
    return 0 if $self->y == $self->board->size && $self->x != 0;
    return $self->y;
}

sub stringify {
    my $self = shift;
    return sprintf '#%d <%d,%d>', $self->id, $self->x, $self->y;
}

sub is_adjacent_to {
    my ($self, $hex) = @_;
    my ($dx, $dy) = ($hex->x - $self->x, $hex->y - $self->y);
    return $dy == +1 || $dy == -1 if $dx ==  0;
    return $dy ==  0 || $dy == +1 if $dx == +1;
    return $dy == -1 || $dy ==  0 if $dx == -1;
}

1;
