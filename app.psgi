use strict;
use warnings;
use EulerGetter::Game;
use EulerGetter::Board;
use Plack::Request;
use Text::MicroTemplate::File;
use Path::Class;

my $Root = file(__FILE__)->dir;

our $mtf = Text::MicroTemplate::File->new(
    include_path => [ $Root->subdir('root') ],
);

my $game = EulerGetter::Game->new(
    board => EulerGetter::Board->new(4),
    turn => 0,
);

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

    if ($req->path_info eq '/update') {
        my $x = $req->param('x');
        my $y = $req->param('y');
        my $hex = $game->board->hex_at($x, $y) or die;
        if ($hex->color) {
            die;
        }
        $hex->color($req->param('color'));
        $game->proceed;
    }

    my $content = $mtf->render_file('index.mt', game => $game);
    return [
        200,
        [ 'Content-Type', 'text/html; charset=utf-8' ],
        [ $content ],
    ];
};

__END__

 a b   a: (-1,-1)
c * e  b: ( 0,-1)
 f g   c: (-1, 0)
       *: ( 0, 0)
       e: ( 1, 0)
       f  ( 0, 1)
       g: ( 1, 1)
