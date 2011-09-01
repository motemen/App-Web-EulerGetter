package EulerGetter::Board;
use strict;
use warnings;
use EulerGetter::Hex;
use Class::Accessor::Lite
    rw => [ 'size', 'hexes' ];

sub new {
    my ($class, $size) = @_;
    my $self = bless { size => $size }, $class;

    my @hexes;
    for my $y (0 .. $size - 1) {
        my @line;
        for my $x (0 .. $size - 1) {
            push @line, $self->new_hex($x, $y);
        }
        push @hexes, \@line;
    }
    $hexes[ $self->size ][0] = $hexes[0][ $self->size ] = $self->new_hex(0, $self->size);
    $self->hexes(\@hexes);

    return $self;
}

sub new_hex {
    my ($self, $x, $y) = @_;
    return EulerGetter::Hex->new(x => $x, y => $y, board => $self);
}

sub hex_at {
    my ($self, $x, $y) = @_;

    $x += $self->size if $x < 0;
    $y += $self->size if $y < 0;

    if ($x == $self->size || $y == $self->size) {
        ($x, $y) = ($self->size - $x, $self->size - $y);
    }

    return $self->hexes->[$y]->[$x];
}

1;
