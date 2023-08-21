package Authen::HTTP::Signature::Fediverse;

use strict;
use warnings;

use Digest::SHA qw(sha256);
use MIME::Base64;

sub sign {
    my ($req, $from, $signer) = @_;
    my $date = $req->header('date');

    my $digest = digest_body($req->content);
    $req->header(Digest => $digest);

    if(!defined $date){
        $req->date(time);
        $date = $req->header('date');
    }

    $req->header(Host => $req->uri->authority);

    my $signbody = sprintf "date: %s\ndigest: %s", $date, $digest;

    my $sign = &$signer($signbody);
    my $signature =
      sprintf 'keyId="%s",algorithm="rsa-sha256",headers="%s",signature="%s"',
        $from, 'date digest', $sign;
    $req->headers->push_header(Signature => $signature);

    return $req;
}

sub digest_body {
    my ($body) = @_;

    my $digest = sha256($body);
    return 'sha-256=' . encode_base64($digest, "");
}

1;