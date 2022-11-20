on 'configure' => sub {
  requires 'Module::Build', '0.40';
  requires 'Module::Build::Pluggable::CPANfile', '0.04';
};

requires 'Class::Tiny';
requires 'Crypt::OpenSSL::RSA';
requires 'DBD::SQLite';
requires 'DBIx::Connector';
requires 'Digest::SHA';
requires 'File::Slurper';
requires 'Mojolicious', '7.76';
