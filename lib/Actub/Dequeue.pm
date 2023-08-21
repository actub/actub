package Actub::Dequeue;

use strict;
use warnings;

use DBI;
use DBD::SQLite;
use Jonk;

use LWP::UserAgent;
use HTTP::Request::Common;

use Actub::Signature;
use Authen::HTTP::Signature::Fediverse;

use Digest::SHA qw(sha256);
use MIME::Base64;

use Data::Dumper;

sub execute {
    my $dbhj = DBI->connect("dbi:SQLite:dbname=actub_job.sqlite","","");

    my $jonk = Jonk->new($dbhj => {functions => [qw/post/]}) or die;
    my $ua = LWP::UserAgent->new;
    my $job; 
    while ($job = $jonk->find_job) {
        my $res = do_post($ua, $job->arg);
        print $res->as_string;
        $job->completed;
    }
}

sub do_post {
    my ($ua, $arg) = @_;
    my ($from, $to, $content) = split /\n/, $arg;

    my $url = $to . '/inbox';
    print "\n$url\n";

    my $contenttype = 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"';
    my $digest = digest_body($content);

    my $req = POST(
        $url,
        'Content-Type' => $contenttype,
        Content => $content,
        Digest => $digest,
        User_Agent => 'Actub/1.0',
    );

    $req = Authen::HTTP::Signature::Fediverse::sign($req, $from, \&Actub::Signature::sign);
    my $res = $ua->request($req);

    return $res;
}

sub digest_body {
    my ($body) = @_;

    my $digest = sha256($body);
    return 'sha-256=' . encode_base64($digest, "");
}

1;
