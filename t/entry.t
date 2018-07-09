# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl FictionalSpork.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

#use Test::More tests => 1;
use Test::More qw(no_plan);
use DBIx::Connector;
use File::Copy 'copy';

my $conn;

BEGIN {
    copy 'actub_base.sqlite', 't/test_entry.sqlite';

    $conn = DBIx::Connector->new(
	"dbi:SQLite:dbname=t/test_entry.sqlite", '', '', 
	{
	    RaiseError => 1,
	    PrintError => 0,
	    AutoCommit => 1,
	    sqlite_unicode => 1,
	}
	);
  };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use JSON::PP;
use Data::Dumper;
use Actub::Entry;

{
    Actub::Entry::make($conn->dbh, 'new', 'actor');
    pass('');
}
