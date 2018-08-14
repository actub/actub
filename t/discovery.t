use Test::More;
use Test::Mojo;

use Data::Dumper;
use File::Copy 'copy';

use FindBin;
require "$FindBin::Bin/../actub.pl";

BEGIN {
    my $base = "$FindBin::Bin/..";
    $ENV{MOJO_CONFIG} = "$base/t/actub.test.json";
    copy "$base/actub_base.sqlite", "$base/actub_test.sqlite";
}

my $t = Test::Mojo->new('Actub');
$t->ua->max_redirects(1);

$t->get_ok('/.well-known/host-meta')->status_is(200);
$t->content_like('/webfinger/');

$t->get_ok('/.well-known/webfinger?resource=acct:testuser')->status_is(200);

note Dumper($t->tx->res->content->asset->slurp);

done_testing();
