use strict;
use warnings;
use DBIx::Sunny;
use JSON::XS;
use String::Random qw(random_regex);
use Path::Class qw(file);
use HTTP::Status qw(:constants);
use Coro;
use Coro::Signal;

our $Root;
BEGIN { $Root = file(__FILE__)->dir }

use lib $Root->subdir('lib').q();
use Khamul;
use EulerGetter::Game;

root $Root;

router {
    connect '/' => { code => \&index };
    connect '/start' => { code => \&start }, { method => 'POST' };
    connect '/next' => { code => \&game_next }, { method => 'POST' };
    connect '/game/{game_id}' => { code => \&game };
    connect '/game.json' => { code => \&game_json };
    connect '/reload.js' => { code => \&reload_js };
};

fallback \&index;

context_builds (
    dbh => sub {
        my $db_file = $Root->file('db.sqlite');
        return DBIx::Sunny->connect("dbi:SQLite:dbname=$db_file", '', '');
    },
    game_id => sub {
        my $self = shift;
        return $self->route->{game_id} || $self->request->param('game_id');
    },
    game_row => sub {
        my $self = shift;
        return $self->dbh->select_row('SELECT * FROM game WHERE id = ?', $self->game_id) or die 'row not found';
    },
    game => sub {
        my $self = shift;
        my $row = $self->game_row or return;
        return EulerGetter::Game->from_hash(decode_json $row->{content});
    },
    color => sub {
        my $self = shift;
        my $row = $self->game_row or return;
        return $row->{red} eq $self->session->id ? 'red'
             : $row->{blue} eq $self->session->id ? 'blue'
             : undef;
    },
);

sub index {
    my $k = shift;
    return $k->mt('index.mt');
}

sub start {
    my $k = shift;

    my $game_id = random_regex('\w{6}');
    my $game = EulerGetter::Game->new(int($k->req->param('size')) || 4);
    $k->dbh->query('INSERT INTO game (id, red, content, updated_on) VALUES (?, ?, ?, ?)', $game_id, $k->session->id, encode_json($game->as_hash), time());

    return [
        HTTP_FOUND,
        [ Location => $k->request->script_name . "/game/$game_id" ],
        [],
    ];
}

sub game {
    my $k = shift;

    if (!$k->color && !$k->game_row->{blue}) {
        $k->color('blue');
        $k->dbh->query('UPDATE game SET blue = ? WHERE id = ?', $k->session->id, $k->game_id);
    }

    return $k->mt(
        'game.mt', time => $k->game_row->{updated_on},
    );
}

sub game_json {
    my $k = shift;

    return [
        200,
        [ 'Content-Type' => 'application/json' ],
        [ encode_json { time => $k->game_row->{updated_on}, game => $k->game->as_hash } ],
    ];
}

my %Signals;

sub game_next {
    my $k = shift;

    if ($k->color && $k->game->current_color eq $k->color) {
        my $x = $k->request->param('x');
        my $y = $k->request->param('y');
        $k->game->proceed_trun_with_hex($x, $y);
        $k->dbh->query('UPDATE game SET content = ?, updated_on = ? WHERE id = ?', encode_json($k->game->as_hash), time(), $k->game_id);
        if (my $signal = $Signals{ $k->game_id }) {
            $signal->broadcast;
        }
    } else {
        die;
    }

    return [ HTTP_NO_CONTENT, [], [] ];
}

sub reload_js {
    my $k = shift;

    if ($k->game_id) {
        my $signal = $Signals{ $k->game_id } ||= Coro::Signal->new;
        return sub {
            my $respond = shift;
            my $writer = $respond->([ 200, [ 'Content-Type' => 'text/javascript' ] ]);
            async {
                $signal->wait;
                $writer->write('location.reload()');
            };
        };
    } else {
        return [ 404, [], [] ];
    }
}

builder {
    enable 'Session', store => 'File';
    __PSGI__;
};
