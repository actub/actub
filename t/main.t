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

{
    $t->get_ok('/testuser')->status_is(200);

    $t = $t->get_ok('/testuser' =>
            {Accept => 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'}
            )->status_is(200);

    $t->json_like('/url', '/.*testuser.*/');

    $t->json_like('/publicKey/publicKeyPem', '/.*PUBLIC KEY.*/');

    note Dumper($t->tx->res->content->asset->slurp);

    $t = $t->get_ok('/testuser/outbox' =>
            {Accept => 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'}
            )->status_is(200);

    note Dumper($t->tx->res->content->asset->slurp);

    $t = $t->get_ok('/testuser/followers' =>
            {Accept => 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'}
            )->status_is(200);

    note Dumper($t->tx->res->content->asset->slurp);
}

done_testing();
