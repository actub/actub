package Actub::Actor;

use strict;
use warnings;

use WWW::ActivityPub::Actor;

my @context = (
    "https://www.w3.org/ns/activitystreams",
    "https://w3id.org/security/v1",
    );

sub make {
    my ($top, $u) = @_;

    my $key = $u->{public_key};
    $key =~ s/\\n/\n/g;

    my $publickey = {
        id => $top,
        owner => $top,
        publicKeyPem => $key,
    };

    my $actor = WWW::ActivityPub::Actor->new(
        context => \@context,
        id => $top,
        type => 'Person',
        inbox => $top . '/inbox',
        outbox => $top . '/outbox',
        following => $top . '/following',
        followers => $top . '/followers',
        url => $top,
        publicKey => $publickey,
        preferredUsername => 'argrath',
        );

    return $actor;
}
1;
