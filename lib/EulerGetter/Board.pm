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
    for my $y (0 .. $size) {
        my @line;
        for my $x (0 .. $size) {
            push @line, $self->new_hex($x, $y);
        }
        push @hexes, \@line;
    }
    # $hexes[ $self->size ][0] = $hexes[0][ $self->size ] = $self->new_hex(0, $self->size);
    $self->hexes(\@hexes);

    return $self;
}

sub new_hex {
    my ($self, $x, $y, %args) = @_;
    return EulerGetter::Hex->new(x => $x, y => $y, board => $self, color => '', %args);
}

sub hex_at {
    my ($self, $x, $y) = @_;

    # $x += $self->size if $x < 0;
    # $y += $self->size if $y < 0;

    # if ($x == $self->size || $y == $self->size) {
    #     ($x, $y) = ($self->size - $x, $self->size - $y);
    # }

    return $self->hexes->[$y]->[$x];
}

sub all_hexes {
    my $self = shift;
    my @hexes;
    for my $x (0 .. $self->size) {
        for my $y (0 .. $self->size) {
            push @hexes, $self->hex_at($x, $y);
        }
    }
    push @hexes, $self->hex_at(0, $self->size);
    return @hexes;
}

sub hex_at_dir {
    my ($self, $x, $y, $dx, $dy) = @_;
    if (($x == 0 && $dx < 0) || ($y == 0 && $dy < 0)) {
        ($x, $y) = ($self->size - $x, $self->size - $y);
    }
    return $self->hex_at($x + $dx, $y + $dy);
}

sub hexes_of_id {
    my ($self, $id) = @_;
    return grep { $_->id == $id } $self->all_hexes;
}

sub as_hash {
    my $self = shift;
    return {
        size  => $self->size,
        hexes => [
            map {
                [ map { $_->color } @$_ ]
            } @{ $self->hexes }
        ],
    };
}

sub from_hash {
    my ($class, $hash) = @_;
    my $size = $hash->{size};
    my $self = bless { size => $size }, $class;

    my @hexes;
    for my $y (0 .. $size) {
        my @line;
        for my $x (0 .. $size) {
            push @line, $self->new_hex($x, $y, color => $hash->{hexes}->[$y]->[$x]);
        }
        push @hexes, \@line;
    }
    $self->hexes(\@hexes);

    return $self;
}

1;
