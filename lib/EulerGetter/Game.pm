package EulerGetter::Game;
use strict;
use warnings;
use EulerGetter::Board;
use Class::Accessor::Lite
    rw => [ 'board', 'turn' ];

use constant COLORS => [ 'red', 'blue' ];

sub new {
    my ($class, $size) = @_;
    return bless {
        board => EulerGetter::Board->new($size),
        turn => 0,
    }, $class;
}

sub current_color {
    my $self = shift;
    return COLORS->[ $self->turn % 2 ];
}

sub hexes_of_color {
    my ($self, $color) = @_;
    return grep { $_->color eq $color } $self->board->all_hexes;
}

sub proceed_trun_with_hex {
    my ($self, $x, $y) = @_;

    my $hex = $self->board->hex_at($x, $y) or die;
    die if $hex->color;

    my @hexes = $self->board->hexes_of_id($hex->id);
    $_->color($self->current_color) for @hexes;

    $self->{turn}++;
}

sub euler_score_of_color {
    my ($self, $color) = @_;

    my @hexes = $self->hexes_of_color($color);
    my (%vertices, %edges, %faces);

    foreach my $hex (@hexes) {
        warn "hex:$hex";
        $faces{ $hex->id }++;

        foreach my $hex2 ($hex->nexts) {
            next unless $hex2->color eq $color;
            warn "hex,hex2:$hex,$hex2";

            my $key = join ',', map $_->id, ($hex, $hex2);
            $edges{$key}++;

            foreach my $hex3 ($hex->nexts) {
                next unless $hex3->color eq $color;
                next unless $hex3->is_adjacent_to($hex2);
                warn "hex,hex2,hex3:$hex,$hex2,$hex3";

                my $key = join ',', map $_->id, ($hex, $hex2, $hex3);
                $vertices{$key}++;
            }
        }
    }

    warn sprintf "$color v:%d e:%d n:%d", scalar(keys %vertices), scalar(keys %edges), scalar(keys %faces);
    return scalar(keys %vertices) - scalar(keys %edges) + scalar(keys %faces);
}

sub as_hash {
    my $self = shift;

    return {
        board => $self->board->as_hash,
        turn  => $self->turn,
    };
}

sub from_hash {
    my ($class, $hash) = @_;

    return bless {
        board => EulerGetter::Board->from_hash($hash->{board}),
        turn  => $hash->{turn},
    }, $class
}

1;
