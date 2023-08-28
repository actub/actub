package Actub::Following;

use strict;
use warnings;

use WWW::ActivityPub::OrderedCollection;

my @context = (
    "https://www.w3.org/ns/activitystreams",
    "https://w3id.org/security/v1",
     );

sub make {
    my ($top, $items) = @_;
    my $outbox = WWW::ActivityPub::OrderedCollection->new(
        orderedItems => $items);

    $outbox->context(\@context);
    $outbox->id($top . '/following');

    $outbox->totalItems($#{$items} + 1);
    $outbox->orderedItems($items);

    return $outbox;
}
1;
