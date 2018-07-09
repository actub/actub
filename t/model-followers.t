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
    copy 'actub_base.sqlite', 't/test_followers.sqlite';

    $conn = DBIx::Connector->new(
	"dbi:SQLite:dbname=t/test_followers.sqlite", '', '', 
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
use Actub::Model::Followers;

{
    my $res;

    Actub::Model::Followers::insert($conn->dbh, {
        user => 'testuser',
        actor => 'testactor'});
    pass('add 1');

    $res = Actub::Model::Followers::read_all($conn->dbh);

    is($#$res, 0, 'actor count is 1');
    is($$res[0]{actor}, 'testactor', 'correct actor');

    Actub::Model::Followers::insert($conn->dbh, {
        user => 'testuser2',
        actor => 'testactor'});
    pass('add 2');

    $res = Actub::Model::Followers::read_all($conn->dbh);

    is($#$res, 1, 'actor count is 2');
    is($$res[0]{actor}, 'testactor', 'correct actor');

    $res = Actub::Model::Followers::read_user($conn->dbh, 'testuser');

    is($#$res, 0, 'read_user 1');
    is($$res[0]{actor}, 'testactor', 'read_user name');

    Actub::Model::Followers::delete($conn->dbh, {
        user => 'testuser',
        actor => 'testactor'});
    pass('delete 1');

    $res = Actub::Model::Followers::read_all($conn->dbh);

    is($#$res, 0, 'actor count is 1');
}
