package WWW::ActivityPub::OrderedCollection;

use strict;
use warnings;

use parent qw(WWW::ActivityPub::Base);

use Class::Tiny qw(context id type totalItems orderedItems);

sub BUILD {
    my ($self, $args) = @_;
    $self->type('OrderedCollection');
    $self->totalItems($#{$self->orderedItems} + 1);
}

1;
