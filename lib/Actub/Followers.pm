package Actub::Followers;

use strict;
use warnings;

use Actub::Model::Followers;

use WWW::ActivityPub::OrderedCollection;

my @context = (
    "https://www.w3.org/ns/activitystreams",
    "https://w3id.org/security/v1",
    );

sub add {
    my ($dbh, $user, $actor, $id) = @_;

    Actub::Model::Followers::insert($dbh, {
        user => $user,
        actor => $actor,
    });
}

sub delete {
    my ($dbh, $user, $actor, $id) = @_;

    Actub::Model::Followers::delete($dbh, {
        user => $user,
        actor => $actor,
    });
}

sub make {
    my ($top, $items) = @_;
    my $outbox = WWW::ActivityPub::OrderedCollection->new(
        orderedItems => $items);

    $outbox->context(\@context);
    $outbox->id($top . '/followers');

    $outbox->totalItems($#{$items} + 1);
    $outbox->orderedItems($items);

    return $outbox;
}
1;
