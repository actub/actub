package Actub::Outbox;

use strict;
use warnings;

use WWW::ActivityPub::OrderedCollection;

my @context = (
    "https://www.w3.org/ns/activitystreams",
    "https://w3id.org/security/v1",
    {
        manuallyApprovesFollowers => "as:manuallyApprovesFollowers",
        sensitive => "as:sensitive",
        hashtag => "as:Hashtag",
        ostatus => "http://ostatus.org#",
        atomUri => "ostatus:atomUri",
        inReplyToAtomUri => "ostatus:inReplyToAtomUri",
        conversation => "ostatus:conversation",
    },
    );

sub make {
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
