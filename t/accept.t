# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl FictionalSpork.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

#use Test::More tests => 2;
use Test::More qw(no_plan);
BEGIN { use_ok('Actub::Accept') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use JSON::PP;
use Data::Dumper;
use Actub::Accept;
use DBIx::Connector;
use File::Copy 'copy';

my $json = JSON::PP->new->convert_blessed(1);

my $top = 'https://actub.ub32.org/argrath';

my $follow = {
    'object' => 'http://192.168.1.8/argrath',
    '@context' => [
        'https://www.w3.org/ns/activitystreams',
        'https://w3id.org/security/v1',
        ],
    'type' => 'Follow',
    'id' => 'http://192.168.1.200/users/admin#follows/3',
    'actor' => 'http://192.168.1.200/users/admin'
  };

my $conn;

BEGIN {
    copy 'job_base.sqlite', 't/test_job.sqlite';

    $conn = DBIx::Connector->new(
	"dbi:SQLite:dbname=t/test_job.sqlite", '', '', 
	{
	    RaiseError => 1,
	    PrintError => 0,
	    AutoCommit => 1,
	    sqlite_unicode => 1,
	}
	);
  };

{
    my $accept = Actub::Accept::make(
        {
            id => 'https://actub.ub32.org/argrath/acccept/follow/',
            actor => 'argrath',
            follow => $follow,
        }
    );

    note $json->encode($accept);

    pass('pass1');
}

{
    Actub::Accept::enqueue($conn->dbh, $top, $follow);

    pass('pass2');
}

