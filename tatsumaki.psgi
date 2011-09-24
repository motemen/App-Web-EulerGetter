use strict;
use warnings;

package EulerGetter::Tatsumaki::Handler;
use Mouse;
use Tatsumaki::MessageQueue;
use Plack::Session;
use Path::Class;
use DBIx::Sunny;
use JSON::XS;

our $Root;
BEGIN { $Root = file(__PACKAGE__)->dir }

use lib $Root->subdir('lib').q();
use EulerGetter::Game;

extends 'Tatsumaki::Handler';

has game_id => ( is => 'rw' );

has color    => ( is => 'rw', lazy_build => 1 );

has dbh      => ( is => 'ro', lazy_build => 1 );
has game_row => ( is => 'ro', lazy_build => 1 );
has game     => ( is => 'ro', isa => 'EulerGetter::Game', lazy_build => 1);
has mq       => ( is => 'ro', isa => 'Tatsumaki::MessageQueue', lazy_build => 1);
has session  => ( is => 'ro', isa => 'Plack::Session', lazy_build => 1 );

sub _build_dbh {
    my $db_file = $Root->file('db.sqlite');
    return DBIx::Sunny->connect("dbi:SQLite:dbname=$db_file", '', '');
}

sub _build_game_row {
    my $self = shift;
    return $self->dbh->select_row('SELECT * FROM game WHERE id = ?', $self->game_id) or die 'row not found';
}

sub _build_game {
    my $self = shift;
    my $row = $self->game_row or return;
    return EulerGetter::Game->from_hash(decode_json $row->{content});
}

sub _build_color {
    my $self = shift;
    my $row = $self->game_row or return;
    return $row->{red}  eq $self->session->id ? 'red'
         : $row->{blue} eq $self->session->id ? 'blue'
         : undef;
}

sub _build_mq {
    my $self = shift;
    return Tatsumaki::MessageQueue->instance($self->game_id);
}

sub _build_session {
    my $self = shift;
    return Plack::Session->new($self->request->env);
}

package IndexHandler;
use parent -norequire => 'EulerGetter::Tatsumaki::Handler';

sub get {
    my $self = shift;
    $self->render('index.html');
}

package StartHandler;
use parent -norequire => 'EulerGetter::Tatsumaki::Handler';
use String::Random qw(random_regex);
use JSON::XS;

sub post {
    my $self = shift;

    my $game_id = random_regex('\w{6}');
    my $game = EulerGetter::Game->new(
        int($self->request->parameters->{'size'} || 4)
    );
    $self->dbh->query(
        'INSERT INTO game (id, red, content, updated_on) VALUES (?, ?, ?, ?)',
        $game_id, $self->session->id, encode_json($game->as_hash), time()
    );
    $self->response->redirect(
        $self->request->script_name . "/game/$game_id"
    );
}

package GameHandler;
use parent -norequire => 'EulerGetter::Tatsumaki::Handler';

sub get {
    my ($self, $game_id) = @_;
    $self->game_id($game_id);

    if (!$self->color && !$self->game_row->{blue}) {
        $self->color('blue');
        $self->dbh->query('UPDATE game SET blue = ? WHERE id = ?', $self->session->id, $self->game_id);
    }

    $self->render('game.html');
}

package GamePollHandler;
use parent -norequire => 'EulerGetter::Tatsumaki::Handler';

__PACKAGE__->asynchronous(1);

sub get {
    my ($self, $game_id) = @_;
    $self->game_id($game_id);

    $self->mq->poll_once($self->session->id, sub {
        warn "recv >>> " , $self->mq->channel;
        $self->write(\@_);
        $self->finish;
    });
}

package GameNextHandler;
use parent -norequire => 'EulerGetter::Tatsumaki::Handler';
use JSON::XS;

sub post {
    my ($self, $game_id) = @_;
    $self->game_id($game_id);

    if ($self->color && $self->game->current_color eq $self->color) {
        my $x = $self->request->parameters->{x};
        my $y = $self->request->parameters->{y}; # }}
        $self->game->proceed_trun_with_hex($x, $y);
        $self->dbh->query(
            'UPDATE game SET content = ?, updated_on = ? WHERE id = ?',
            encode_json($self->game->as_hash), time(), $self->game_id
        );
        warn "send <<< " , $self->mq->channel;
        $self->mq->publish({
            event => 'turn',
            game  => $self->game->as_hash,
        });

        $self->write({ success => \1 });
    } else {
        die;
    }
}

package main;
use Tatsumaki::Application;
use File::Basename;
use Plack::Builder;

my $game_id_re = qr/\w{6}/;
my $app = Tatsumaki::Application->new([
    '/'                          => 'IndexHandler',
    '/start$'                    => 'StartHandler',
    "/game/($game_id_re)/poll\$" => 'GamePollHandler',
    "/game/($game_id_re)/next\$" => 'GameNextHandler',
    "/game/($game_id_re)\$"      => 'GameHandler',
]);

$app->template_path(dirname(__FILE__) . '/templates');
$app->static_path(dirname(__FILE__) . '/static');

builder {
    enable 'Session', store => 'File';
    $app->psgi_app;
};
