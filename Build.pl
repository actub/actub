use Module::Build;
use Module::Build::Pluggable qw(
    CPANfile
);

my $build = Module::Build::Pluggable->new
  (
   module_name => 'Actub',
   license  => 'perl',
   dist_author => 'SHIRAKATA Kentaro <argrath@ub32.org>',
   dist_version_from => 'actub.pl',
   dist_abstract => 'actub.pl',
  );
$build->create_build_script;
