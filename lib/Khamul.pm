package Khamul;
use strict;
use warnings;
use Text::MicroTemplate::File;

sub import {
    my $class = shift;
    my $pkg = caller;

    eval qq{
        package $pkg;
        use Router::Simple::Declare;
        use Plack::Builder;
    };
    die $@ if $@;

    no strict 'refs';
    no warnings 'redefine';
    *{ "$pkg\::__PSGI__" } = \&__PSGI__;
    *{ "$pkg\::root" } = \&root;
    *{ "$pkg\::router" } = \&__router;
    *{ "$pkg\::fallback" } = \&__fallback;
    *{ "$pkg\::context_builds" } = \&__context_builds;
}

sub __router (&) {
    our $Router = Router::Simple::Declare::router(\&{$_[0]});
}

sub router {
    our $Router;
}

sub root {
    our $Root = shift if @_;
    return $Root;
}

sub __fallback (&) {
    our $Fallback = $_[0];
}

sub __context_builds {
    my %decls = @_;

    while (my ($name, $builder) = each %decls) {
        my $code = sub {
            my $self = shift;
            if (@_) {
                $self->{$name} = $_[0];
            }
            return $self->{$name} if exists $self->{$name};
            return $self->{$name} = $self->$builder;
        };

        no strict 'refs';
        *{ "Khamul::$name" } = $code;
    }
}

our $K;

sub __PSGI__ {
    return sub {
        my $env = shift;
        local $K = Khamul->new($env);
        if ($K->route) {
            return $K->route->{code}->($K);
        } else {
            return our $Fallback->($K);
        }
    };
}

sub K { $K }

sub new {
    my ($class, $env) = @_;
    return bless { env => $env }, $class;
}

sub env { $_[0]->{env} }

sub request {
    my $self = shift;
    require Plack::Request;
    return $self->{request} ||= Plack::Request->new($self->env);
}

sub session {
    my $self = shift;
    require Plack::Session;
    return $self->{session} ||= Plack::Session->new($self->env);
}

sub route {
    my $self = shift;
    return $self->{route} ||= Khamul->router->match($self->env);
}

*req = \&request;

sub mtf {
    my $self = shift;
    return our $mtf ||= Text::MicroTemplate::File->new(
        include_path => [ Khamul::root->subdir('khamul') ]
    );
}

sub mt {
    my $self = shift;
    return [
        200,
        [ 'Content-Type' => 'text/html; charset=utf-8' ],
        [ $self->mtf->render_file(@_) ],
    ];
}

1;
