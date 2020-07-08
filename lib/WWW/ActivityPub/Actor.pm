package WWW::ActivityPub::Actor;

use strict;
use warnings;

use parent qw(WWW::ActivityPub::Base);

use Class::Tiny qw(
    context id type following followers inbox outbox name url publicKey preferredUsername
    );

1;
