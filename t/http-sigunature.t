use strict;
use warnings;

use HTTP::Request::Common;

#use Test::More tests => 1;
use Test::More qw(no_plan);

BEGIN { use_ok('Authen::HTTP::Signature::Fediverse') };

{
    my $req = POST(
        'https://example.com/foo/bar?baz',
        Content => 'content',
        Digest => 'digest',
    );

    note_req($req);
    $req = Authen::HTTP::Signature::Fediverse::sign($req, 'dummyKeyId', \&test_signer, 'DummyPK');
    my $sig = $req->header('Signature');

    note 'newhost:' . $req->headers->header('host');
    note 'Sig:' . $sig;

    like($sig, qr/headers="\(request-target\) host date digest"/, "POST headers");
}

{
    my $req = GET(
        'https://example.com/foo/bar?baz',
    );

    note_req($req);
    $req = Authen::HTTP::Signature::Fediverse::sign($req, 'dummyKeyId', \&test_signer, 'DummyPK');
    my $sig = $req->header('Signature');

    note 'newhost:' . $req->headers->header('host');
    note 'Sig:' . $sig;

    like($sig, qr/headers="\(request-target\) host date"/, "GET headers");
}

#done_testing();

sub note_req {
    my $req = shift;
    note 'authority:' . $req->uri->authority;
    note 'uri:' . $req->uri->authority;
    note 'path:' . $req->uri->path;
    note 'pathquery:' . $req->uri->path_query;
    note 'content:' . $req->content;
}

sub test_signer {
    my ($body, $pk) = @_;
    $body =~ s/\n/<\\n>/g;
    $body = 'testsign:' . $body;
    note $body;
    is($pk, 'DummyPK', 'PK');
    return $body;
}