package WWW::ActivityPub::Note;

use strict;
use warnings;

use parent qw(WWW::ActivityPub::Base);

use Class::Tiny qw(
    id type summary content inReplyTo published url attributedTo to cc
    );

1;
