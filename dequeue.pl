use strict;
use warnings;

use lib 'lib';

use DBI;
use DBD::SQLite;
use Jonk;

use LWP::UserAgent;
use HTTP::Request::Common;

use Actub::Dequeue;

use Data::Dumper;

sub execute {
    my $ua = LWP::UserAgent->new;

    my $dbhj = DBI->connect("dbi:SQLite:dbname=actub_job.sqlite","","");

    my $jonk = Jonk->new($dbhj => {functions => [qw/post/]}) or die;
    my $job = $jonk->find_job;
    if (!defined $job) {
        exit 0;
    }
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

    my $sign = Actub::Dequeue::sign('date: ' . $date);

    my $signature = sprintf 'keyId="%s",algorithm="rsa-sha256",signature="%s"', $from, $sign;

    $req->headers->push_header(Signature => $signature);

    my $res = $ua->request($req);

#print Dumper($res);

    print $res->as_string;

    $job->completed;
}

execute;
