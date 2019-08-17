# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl FictionalSpork.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

#use Test::More tests => 1;
use Test::More qw(no_plan);
BEGIN { use_ok('Actub::Outbox') };

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
    my $outbox = Actub::Outbox::make($top, [{
        id => '1',
        datetime => 2,
        message => 'messagetest',
    }]);

    note $json->encode($outbox);
    pass('');
}
