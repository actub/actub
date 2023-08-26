package Authen::HTTP::Signature::Fediverse;

use strict;
use warnings;

use Digest::SHA qw(sha256);
use MIME::Base64;

my @headerlist = ('(request-target)', 'host', 'date', 'digest');

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

    my $signbody = make_signbody($req, \@headerlist);

    my $sign = &$signer($signbody);
    my $signature =
      sprintf 'keyId="%s",algorithm="rsa-sha256",headers="%s",signature="%s"',
        $from, join(' ', @headerlist), $sign;
    $req->headers->push_header(Signature => $signature);

    return $req;
}

sub make_signbody {
    my ($req, $list) = @_;
    my (@r) = ();

    for(@$list){
        my $v;
        if($_ eq '(request-target)'){
            $v = sprintf "%s %s",
                lc($req->method),
                $req->uri->path_query;
        } else {
            $v = $req->header($_);
        }
        push @r, sprintf '%s: %s', $_, $v;
    }

    return join "\n", @r;
}

sub digest_body {
    my ($body) = @_;

    my $digest = sha256($body);
    return 'sha-256=' . encode_base64($digest, "");
}

1;