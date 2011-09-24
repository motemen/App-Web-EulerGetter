use inc::Module::Install;

name 'App-Web-EulerGetter';
version '0.2';
license 'perl';

requires 'Tatsumaki';
requires 'Plack::Middleware::Session';
requires 'JSON::XS';
requires 'String::Random';
requires 'Path::Class';
requires 'DBIx::Sunny';

WriteAll;
