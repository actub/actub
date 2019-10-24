package Actub::Accept;

use strict;
use warnings;

use WWW::ActivityPub::Accept;
use WWW::ActivityPub::Follow;

use Jonk;

use JSON::PP;

my @context = (
    "https://www.w3.org/ns/activitystreams",
    "https://w3id.org/security/v1",
    );

sub make {
    my ($u) = @_;

    my $f = $u->{follow};

    my $object = {
        type => 'Follow',
        id => $f->{id},
        actor => $f->{actor},
        object => $f->{object},
    };

    my $accept = WWW::ActivityPub::Accept->new(
        context => \@context,
        type => 'Accept',
        id => $u->{id},
        actor => $u->{actor},
        object => $object,
    );

    return $accept;
}

sub enqueue {
    my ($dbh, $actor, $decoded) = @_;

    my $jonk = Jonk->new($dbh);

    my $json = JSON::PP->new->convert_blessed(1);

    my $baseid = $decoded->{id};
    $baseid =~ s@http(s)://@@;
    my $accept = make({
        id => sprintf('%s/acccept/follow/%s', $actor, $baseid),
        actor => $actor,
        follow => $decoded,
    });
    my $acceptstr = $json->encode($accept);
    my $queuestr = join('\n', $actor, $decoded->{actor}, $acceptstr);
    my $job_id = $jonk->insert('post', $queuestr);
}

1;
