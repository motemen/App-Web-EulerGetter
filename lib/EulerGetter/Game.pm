package EulerGetter::Game;
use strict;
use warnings;
use EulerGetter::Board;
use List::MoreUtils qw(any);
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

    my (%vertices, %edges, %faces);

    foreach my $hex ($self->board->all_hexes) {
        $faces{ $hex->id }++ if any { $_->color eq $color } $hex;

        foreach my $hex2 ($hex->nexts) {
            # next unless $hex2->color eq $color;

            my $key = join ',', sort { $a <=> $b } map $_->id, ($hex, $hex2);

            # XXX special case
            if ($hex->x == 0 && $hex->y == $self->board->size - 1
                && $hex2->x == 1 && $hex2->y == $self->board->size) {
                $key = join ',', map $_->id, ($hex, $hex2);
            }
            $edges{$key}++ if any { $_->color eq $color } $hex, $hex2;

            foreach my $hex3 ($hex2->nexts) {
                # next unless $hex3->color eq $color;
                next unless $hex3->is_adjacent_to($hex);

                my @hexes = ( $hex, $hex2, $hex3 );
                for (1 .. 3) {
                    if ($hexes[1]->id < $hexes[0]->id) {
                        push @hexes, shift @hexes;
                    }
                }

                my $key = join ',', map $_->id, @hexes;
                $vertices{$key}++ if any { $_->color eq $color } $hex, $hex2, $hex3;
            }
        }
    }

    warn sprintf "$color v:%d e:%d n:%d", scalar(keys %vertices), scalar(keys %edges), scalar(keys %faces);
    warn "e=" . join ' ', keys %edges;
    warn "v=" . join ' ', keys %vertices;
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
