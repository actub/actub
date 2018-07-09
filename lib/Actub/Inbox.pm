package Actub::Inbox;

use strict;
use warnings;

use WWW::ActivityPub::OrderedCollection;

my @context = (
    "https://www.w3.org/ns/activitystreams",
    "https://w3id.org/security/v1",
    );

sub parse {
    my ($top, $entries) = @_;
    my @items;

    for(@$entries){
        my $note = Actub::Activity::make_note($top, $_);
        my $item = Actub::Activity::make('Create', $top, $note);
        push @items, $item;
    }

    my $outbox = WWW::ActivityPub::OrderedCollection->new(
        context => \@context,
        id => $top . '/outbox',
        orderedItems => \@items
        );

    return $outbox;
}
1;
