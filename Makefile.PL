use inc::Module::Install;

name 'App-Web-EulerGetter';
version '0.1';
license 'perl';

requires 'Plack';
requires 'Plack::Middleware::Session';
requires 'Router::Simple';
requires 'JSON::XS';
requires 'String::Random';
requires 'Text::MicroTemplate::File';
requires 'Path::Class';
requires 'DBIx::Sunny';

WriteAll;
