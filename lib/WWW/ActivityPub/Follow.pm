package WWW::ActivityPub::Follow;

use strict;
use warnings;

use parent qw(WWW::ActivityPub::Base);

use Class::Tiny qw(
    context id type object preferredUsername
    );

1;
