use strict;
use warnings;

use lib 'lib';

use DBI;
use DBD::SQLite;
use Jonk;

use LWP::UserAgent;
use HTTP::Request::Common;

use Actub::Signature;

use Data::Dumper;

sub execute {
    my $dbhj = DBI->connect("dbi:SQLite:dbname=actub_job.sqlite","","");

    my $jonk = Jonk->new($dbhj => {functions => [qw/post/]}) or die;
    my $job; 
    while ($job = $jonk->find_job) {
        do_post($job->arg);
        $job->completed;
    }
}

sub do_post {
    my ($from, $to, $content) = split /\n/, $_[0];
    my $ua = LWP::UserAgent->new;

    my $url = $to . '/inbox';

    my $contenttype = 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"';
    my $req = POST(
        $url,
        'Content-Type' => $contenttype,
        Content => $content
    );

    $req->headers->date(time);
    my $date = $req->headers->header('date');
    my $sign = Actub::Signature::sign('date: ' . $date);
    my $signature =
      sprintf 'keyId="%s",algorithm="rsa-sha256",signature="%s"',
        $from, $sign;
    $req->headers->push_header(Signature => $signature);

    my $res = $ua->request($req);

#print Dumper($res);

    print $res->as_string;
}

execute;
