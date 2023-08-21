package Authen::HTTP::Signature::Fediverse;

use strict;
use warnings;

sub sign {
    my ($req, $from, $signer) = @_;
    my $date = $req->headers->header('date');
    my $digest = $req->headers->header('digest');

    if(!defined $date){
        $req->headers->date(time);
        $date = $req->headers->header('date');
    }

    my $signbody = sprintf "date: %s\ndigest: %s", $date, $digest;

    my $sign = &$signer($signbody);
    my $signature =
      sprintf 'keyId="%s",algorithm="rsa-sha256",headers="%s",signature="%s"',
        $from, 'date digest', $sign;
    $req->headers->push_header(Signature => $signature);

    return $req;
}

1;