package Actub;

use Mojo::Base 'Mojolicious';
use utf8;
use Encode qw/encode decode/;

use lib 'lib';
use Actub::Model::Entry;

use Actub::Activity;
use Actub::Entry;
use Actub::Outbox;
use Actub::Followers;
use Actub::Actor;
use Actub::Accept;

use Actub::Model::Received;

use JSON::PP;

use DBI;
use DBIx::Connector;

use Data::Dumper;

our $VERSION = '0.1';

has 'conn';
has 'jobconn';

has 'json';

sub startup {
    my $self = shift;

    my $app = $self->app;

    $self->plugin('JSONConfig');

    $app->config(
        hypnotoad => {
            listen => ['http://127.0.0.1:3000'],
            workers => 2,
        },
    );

    $self->types->type(as => 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"');

    {
        my $dbfile = $app->config('dbfile');

        if(!defined $dbfile) {
            $dbfile = 'actub.sqlite'
        }

        my $conn = DBIx::Connector->new(
            'dbi:SQLite:dbname=' . $dbfile, '', '',
            {
                RaiseError => 1,
                PrintError => 0,
                AutoCommit => 1,
                sqlite_unicode => 1,
            }
        );

        $self->conn($conn);
    }

    {
        my $dbfile = $app->config('dbjobfile');

        if(!defined $dbfile) {
            $dbfile = 'actub_job.sqlite'
        }

        print "$dbfile\n";

        my $conn = DBIx::Connector->new(
            'dbi:SQLite:dbname=' . $dbfile, '', '',
            {
                RaiseError => 1,
                PrintError => 0,
                AutoCommit => 1,
                sqlite_unicode => 1,
            }
        );

        $self->jobconn($conn);
    }

    {
        my $json = JSON::PP->new;
        $json = $json->convert_blessed(1);
        $self->json($json);
    }

    my $r = $self->routes;

    $r->get('/(:name)/new')->to('edit#newform')->name('post');

    $r->post('/(:name)/new/create')->to('edit#create')->name('create');

    $r->get('/(:name)')->to('resource#actor')->name('index');

    $r->post('/(:name)/inbox')->to('receive#inbox');

    $r->get('/(:name)/outbox')->to('resource#outbox');

    $r->get('/(:name)/followers')->to('resource#followers');

    $r->get('/(:name)/(:id)')->to('resource#entry')->name('entry');

    # server

    $r->get('/.well-known/host-meta')->to('discovery#hostmeta');

    $r->get('/.well-known/webfinger')->to('discovery#webfinger');

    $self->helper(datetime => sub {
        my ($self, $arg) = @_;
        return POSIX::strftime "%Y/%m/%d %H:%M:%S", localtime($arg);
    });
    $self->helper(w3cdate => sub {
        my ($self, $arg) = @_;
        return POSIX::strftime "%Y-%m-%dT%H:%M:%SZ", gmtime($arg);
    });
}

1;
