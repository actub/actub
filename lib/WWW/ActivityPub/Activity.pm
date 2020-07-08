package WWW::ActivityPub::Activity;

use strict;
use warnings;

use parent qw(WWW::ActivityPub::Base);

use Class::Tiny qw(
    id type actor to cc object
    );

1;
