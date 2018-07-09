on 'configure' => sub {
  requires 'Module::Build', '0.40';
  requires 'Module::Build::Pluggable::CPANfile', '0.04';
};

requires 'Class::Tiny';
requires 'DBD::SQLite';
requires 'DBIx::Connector';
requires 'Mojolicious', '>= 6.64, < 7.75';
