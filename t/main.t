use Test::More;
use Test::Mojo;

use Data::Dumper;
use File::Copy 'copy';

use FindBin;
require "$FindBin::Bin/../actub.pl";

BEGIN {
    my $base = "$FindBin::Bin/..";
    $ENV{MOJO_CONFIG} = "$base/t/actub.test.json";
    copy "$base/actub_test_base.sqlite", "$base/actub_test.sqlite";
}

my $t = Test::Mojo->new('Actub');
$t->ua->max_redirects(1);

my $as = {Accept => 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'};

{
    $t->get_ok('/.well-known/host-meta')->status_is(200);
    $t->content_like(qr/webfinger/);
    note $t->tx->res->content->asset->slurp;

    $t->get_ok('/.well-known/webfinger?resource=testuser@127.0.0.1')->status_is(200);
    $t->content_like(qr/self/);
    note $t->tx->res->content->asset->slurp;

    $t->get_ok('/nosuchuser')->status_is(404, 'user not found');

    $t->get_ok('/testuser')->status_is(200);

    $t = $t->get_ok('/testuser/new')->status_is(401, 'open form');

    $url = $t->ua->server->url->userinfo('testuser:password')->path('/testuser/new');
    $t->get_ok($url)->status_is(200, 'open form 2');

    $t = $t->get_ok('/testuser' => $as)->status_is(200);
    $t->json_like('/url', '/.*testuser.*/');
    $t->json_like('/publicKey/publicKeyPem', '/.*PUBLIC KEY.*/');
    note Dumper($t->tx->res->content->asset->slurp);

    $t = $t->get_ok('/testuser/outbox' => $as)->status_is(200);
    $t->json_is('/type' => 'orderedCollection');
    note Dumper($t->tx->res->content->asset->slurp);

    $t = $t->get_ok('/testuser/followers' => $as)->status_is(200, 'followers');
    note Dumper($t->tx->res->content->asset->slurp);

    $t = $t->get_ok('/testuser/following' => $as)->status_is(200, 'following');
    note Dumper($t->tx->res->content->asset->slurp);

    $t = $t->get_ok('/testuser/20180816213708' => $as)->status_is(200, "existing entry");
    note Dumper($t->tx->res->content->asset->slurp);

    $t = $t->get_ok('/testuser/nosuchentry' => $as)->status_is(404, 'entry not found');
}

done_testing();
