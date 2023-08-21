use strict;
use warnings;

use HTTP::Request::Common;

#use Test::More tests => 1;
use Test::More qw(no_plan);

BEGIN { use_ok('Authen::HTTP::Signature::Fediverse') };

my $req = POST(
    'https://example.com/foo/bar',
    Content => 'content',
    Digest => 'digest',
);
#$req->headers->date(time);

note $req->headers->header('host');
note $req->uri->path_query;

$req = Authen::HTTP::Signature::Fediverse::sign($req, '', \&test_signer);

done_testing();

sub test_signer {
    my $body = shift;
    note $body;
    return $body;
}