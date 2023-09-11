use Test::More;
use Test::Mojo;

use Data::Dumper;
use File::Copy 'copy';

use FindBin;
require "$FindBin::Bin/../actub.pl";

BEGIN {
    my $base = "$FindBin::Bin/..";
    $ENV{MOJO_CONFIG} = "$base/t/actub.test.json";
    copy "$base/actub_test_base.sqlite", "$base/actub_test.sqlite" or fail "$!";;
}

my $t = Test::Mojo->new('Actub');
$t->ua->max_redirects(1);

SKIP: {
    if($ENV{CI} eq 'travis'){
        skip 'On CI, some tests are skipped';
    }

    $t->get_ok('/testuser/new')->status_is(401);

    $t->get_ok('//nosuchuser:password@/testuser/new')->status_is(401);

    $t->get_ok('//testuser:nosuchpassword@/testuser/new')->status_is(401);

    $t->get_ok('//testuser:password@/testuser/new')->status_is(200);

    $t->content_like('/Message/');

    note Dumper($t->tx->res->content->asset->slurp);

    $t = $t->post_ok('//testuser:password@/testuser/new/create' => 
    form => {})->status_is(200);

    $t = $t->post_ok('//testuser:password@/testuser/new/create' => 
    form => {message => 'post test'})->status_is(200);

    $t->content_like('/post test/');

    note Dumper($t->tx->res->content->asset->slurp);
}

done_testing();
