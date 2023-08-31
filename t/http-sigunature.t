use strict;
use warnings;

use HTTP::Request::Common;

#use Test::More tests => 1;
use Test::More qw(no_plan);

BEGIN { use_ok('Authen::HTTP::Signature::Fediverse') };

my $req = POST(
    'https://example.com/foo/bar?baz',
    Content => 'content',
    Digest => 'digest',
);
#$req->headers->date(time);

#note 'oldhost:' . $req->headers->header('host');
note 'authority:' . $req->uri->authority;
note 'uri:' . $req->uri->authority;
note 'path:' . $req->uri->path;
note 'path:' . $req->uri->path_query;

$req = Authen::HTTP::Signature::Fediverse::sign($req, '', \&test_signer, 'DummyPK');

note 'newhost:' . $req->headers->header('host');
note 'Sig:' . $req->header('Signature');

done_testing();

sub test_signer {
    my ($body, $pk) = @_;
    $body =~ s/\n/<\\n>/g;
    $body = 'testsign:' . $body;
    note $body;
    is($pk, 'DummyPK', 'PK');
    return $body;
}