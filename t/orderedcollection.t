use strict;
use warnings;

#use Test::More tests => 1;
use Test::More qw(no_plan);
BEGIN { use_ok('WWW::ActivityPub::OrderedCollection') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use JSON::PP;
use Data::Dumper;
use Actub::Activity;

my $json = JSON::PP->new;
$json = $json->convert_blessed(1);

my $top = 'https://actub.ub32.org/argrath';

{
    my $item = WWW::ActivityPub::OrderedCollection->new(
	orderedItems => []
	);
    note Dumper($item);
}
