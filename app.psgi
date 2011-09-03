use strict;
use warnings;
use Plack::Builder;
use Plack::Request;
use Plack::Session;
use Text::MicroTemplate::File;
use Path::Class;
use DBIx::Sunny;
use Router::Simple::Declare;
use String::Random qw(random_regex);
use JSON::XS;

use EulerGetter::Game;

my $Router = router {
    connect '/' => { action => 'index' };
    connect '/start' => { action => 'start' };
    connect '/next' => { action => 'game_next' };
    connect '/game/{game_id}' => { action => 'game' };
};

my $Root = file(__FILE__)->dir;

our $mtf = Text::MicroTemplate::File->new(
    include_path => [ $Root->subdir('root') ],
);

sub game_and_color {
    my ($dbh, $game_id, $session) = @_;
    my $row = $dbh->select_row('SELECT * FROM game WHERE id = ?', $game_id) or die;
    my $color = $row->{red} eq $session->id ? 'red'
              : $row->{blue} eq $session->id ? 'blue'
              : undef;
    my $game = EulerGetter::Game->from_hash(decode_json $row->{content});
    return ($game, $color, $row);
}

sub index {
    return [ 200, [ 'Content-Type' => 'text/plain' ], [ 'Euler Getter' ] ];
}

sub start {
    my ($req, $session, $dbh, $m) = @_;
    my $game_id = random_regex('\w{6}');
    my $game = EulerGetter::Game->new($req->param('size') || 4);
    $dbh->query('INSERT INTO game (id, red, content) VALUES (?, ?, ?)', $game_id, $session->id, encode_json $game->as_hash);

    return [ 302, [ Location => "/game/$game_id" ], [ ] ];
}

sub game {
    my ($req, $session, $dbh, $m) = @_;

    my $game_id = $m->{game_id} or die;
    my ($game, $color, $row) = game_and_color($dbh, $game_id, $session);

    if (!$color && !$row->{blue}) {
        $color = 'blue';
        $dbh->query('UPDATE game SET blue = ? WHERE id = ?', $session->id, $game_id);
    }

    my $content = $mtf->render_file('index.mt', game => $game, color => $color, game_id => $game_id);
    return [
        200,
        [ 'Content-Type', 'text/html; charset=utf-8' ],
        [ $content ],
    ];
}

sub game_next {
    my ($req, $session, $dbh, $m) = @_;

    my $game_id = $req->param('game_id') or die;
    my ($game, $color) = game_and_color($dbh, $game_id, $session);

    if ($color && $game->current_color eq $color) {
        my $x = $req->param('x');
        my $y = $req->param('y');
        $game->proceed_trun_with_hex($x, $y);
        $dbh->query('UPDATE game SET content = ? WHERE id = ?', encode_json($game->as_hash), $game_id);
    } else {
        die;
    }

    return [ 204, [], [] ];
}

my $app = sub {
    my $env = shift;

    my $db_file = $Root->file('db.sqlite');
    my $dbh = DBIx::Sunny->connect("dbi:SQLite:dbname=$db_file", '', '');

    my $req = Plack::Request->new($env);
    my $session = Plack::Session->new($req->env);

    my $m = $Router->match($env);
    my $action = __PACKAGE__->can($m->{action} || 'index');
    return $action->($req, $session, $dbh, $m);
};

builder {
    enable 'Session';
    $app;
};

__END__

 a b   a: (-1,-1)
c * e  b: ( 0,-1)
 f g   c: (-1, 0)
       *: ( 0, 0)
       e: ( 1, 0)
       f  ( 0, 1)
       g: ( 1, 1)
