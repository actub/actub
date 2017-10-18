use strict;
use warnings;

use lib 'lib';

use DBI;
use DBD::SQLite;
use Jonk;

use LWP::UserAgent;
use HTTP::Request::Common;

use Crypt::OpenSSL::RSA;

use File::Slurper 'read_text';
use JSON::PP;
use MIME::Base64;

use Data::Dumper;

sub execute {
    my $ua = LWP::UserAgent->new;

    my $dbhj = DBI->connect("dbi:SQLite:dbname=actub_job.sqlite","","");

    my $jonk = Jonk->new($dbhj => {functions => [qw/post/]}) or die;
    my $job = $jonk->find_job;
    print $job->func;
    print $job->arg;

    my ($from, $to, $content) = split /\n/, $job->arg;

    my $req = POST(
    $to . '/inbox',
    'Content-Type' => 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"',
    Content => $content
    );

    $req->headers->date(time);

    my $date = $req->headers->header('date');

    my $sign = sign('date: ' . $date);

    my $signature = sprintf 'keyId="%s",algorithm="rsa-sha256",signature="%s"', $from, $sign;

    $req->headers->push_header(Signature => $signature);

    my $res = $ua->request($req);

#print Dumper($res);

    print $res->as_string;

    $job->completed;
}


sub sign {
    my ($data) = shift;

    my $jsonfile = read_text('actub.json');
    my $json = decode_json($jsonfile);

    my $pk = $json->{users}->{argrath}->{private_key};

    my $key = Crypt::OpenSSL::RSA->new_private_key($pk);
    $key->use_sha256_hash();
    my $s = $key->sign($data);

    return encode_base64($s, "");
}

execute;
