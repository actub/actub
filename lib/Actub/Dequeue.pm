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

use Data::Dumper;

use File::Slurper 'read_text';
use JSON::PP;

sub get_pk {
    my $conffile = $ENV{MOJO_CONFIG} // 'actub.json';
    my $jsonfile = read_text($conffile);
    my $json = decode_json($jsonfile);
    my $users = $json->{users};
    my $user = (keys %$users)[0];

    return $users->{$user}->{private_key};
}

sub execute {
    my $dbhj = DBI->connect("dbi:SQLite:dbname=actub_job.sqlite","","");

    my $jonk = Jonk->new($dbhj => {functions => [qw/post/]}) or die;
    my $ua = LWP::UserAgent->new;
    my $pk = get_pk();
    my $job; 
    while ($job = $jonk->find_job) {
        my $res = do_post($ua, $job->arg, $pk);
        print $res->as_string;
        if($res->is_success) {
            $job->completed;
        } else {
            if($job->retry_cnt >= 3) {
                $job->aborted;
            } else {
                $job->failed;
            }
        }
    }
}

sub do_post {
    my ($ua, $arg, $pk) = @_;
    my ($from, $to, $content) = split /\n/, $arg;

    my $url = $to . '/inbox';
    print "\n$url\n";

#    my $contenttype = 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"';
    my $contenttype = 'application/activity+json';

    my $req = POST(
        $url,
        'Content-Type' => $contenttype,
        Content => $content,
        User_Agent => 'Actub/1.0',
    );

    $req = Authen::HTTP::Signature::Fediverse::sign($req, $from, \&Actub::Signature::sign, $pk);
    my $res = $ua->request($req);

    return $res;
}

1;
