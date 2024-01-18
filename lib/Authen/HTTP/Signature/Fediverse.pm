package Authen::HTTP::Signature::Fediverse;

use strict;
use warnings;

use Digest::SHA qw(sha256);
use MIME::Base64;

my %headerlist = (
    POST => ['(request-target)', 'host', 'date', 'digest'],
    GET => ['(request-target)', 'host', 'date'],
);

sub sign {
    my ($req, $from, $signer, $pk) = @_;

    $req->header(Host => $req->uri->authority);

    if(!defined $req->header('date')){
        $req->date(time);
    }

    if($req->content ne ''){
        $req->header(Digest => digest_body($req->content));
    }

    my $list = $headerlist{$req->method};

    my $signbody = make_signbody($req, $list);

    my $sign = &$signer($signbody, $pk);
    my $signature =
      sprintf 'keyId="%s",algorithm="rsa-sha256",headers="%s",signature="%s"',
        $from, join(' ', @$list), $sign;
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
    return 'SHA-256=' . encode_base64($digest, "");
}

1;