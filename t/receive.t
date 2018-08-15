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
    copy "$base/job_base.sqlite", "$base/t/test_job.sqlite";
}

my $t = Test::Mojo->new('Actub');
$t->ua->max_redirects(1);

my $req =<<'EOF'
{
    "@context": "https://www.w3.org/ns/activitystreams",
    "id": "http://192.168.1.8/argrath/follows/1",
    "type": "Follow",
    "actor": "http://192.168.1.8/argrath",
    "object": "http://192.168.1.200/admin"
}
EOF
;

{
    $t = $t->post_ok('/testuser/inbox' =>
            {Accept => 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'} => $req
            )->status_is(200);

    note Dumper($t->tx->res->content->asset->slurp);
}

done_testing();
