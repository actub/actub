package WWW::ActivityPub::Create;

use strict;
use warnings;

use parent qw(WWW::ActivityPub::Base);

use Class::Tiny qw(
    context id type actor to cc object
    );

1;
