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

sub hexes_of_color {
    my ($self, $color) = @_;
    return grep { $_->color eq $color } $self->board->all_hexes;
}

sub euler_score_of_color {
    my ($self, $color) = @_;

    my @hexes = $self->hexes_of_color($color);
    my (%vertices, %edges, %faces);

    foreach my $hex (@hexes) {
        $faces{ $hex->id }++;
        warn "hex:$hex";

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

1;
