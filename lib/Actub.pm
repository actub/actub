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

    my $r = $self->routes;
    $r->post('/(:name)/new/create' => sub {
        my $c = shift;

        my $message = $c->param('message');
        my $actor = $app->config('host') . '/' . $c->param('name');

        return $c->render(template => 'error', message => 'Please input message')
        unless $message;

        my $dbh = $conn->dbh;


        {
            my $create = Actub::Entry::make($dbh, $message, $actor);

            my $actor = $app->config('host') . '/' . $c->param('name');
            my $dbhj = DBI->connect("dbi:SQLite:dbname=actub_job.sqlite", "", "");
            Actub::Entry::enqueue($dbh, $actor, $create, $dbhj);
        }

        $c->redirect_to('/' . $c->param('name'));
        
    } => 'create');

    $r->get('/(:name)' => sub {
        my $c = shift;
        my $name = $c->param('name');
        my $accept = $c->req->headers->accept // '';
        print "accept: $accept\n";
        print "self: $name\n";
        if(!is_user($name, $app->config('users'))){
            $c->reply->not_found;
            return;
        }
        $c->stash(
            domain => $app->config('domain'),
            host => $app->config('host'),
            id => $c->param('name'),
            );
        if(is_ap($accept)){
            my $users = $app->config('users');
            my $u = $users->{$name};
            my $actor = Actub::Actor::make($app->config('host') . '/' . $name, $u);
            my $json = JSON::PP->new;
            $json = $json->convert_blessed(1);
            my $out =  $json->encode($actor);
            $c->render(text => $out, format => 'as');
        } else {
            my $dbh = $conn->dbh;
            my $entries = Actub::Model::Entry::read_top($dbh);
            $c->render(entries => $entries);
        }
    } => 'index');

    $r->get('/(:name)/new' => sub {
        my $self = shift;

        if(!auth($self->req->url->to_abs->userinfo, $app->config('users'))){
            $self->res->headers->www_authenticate('Basic');
            $self->render(text => 'Authentication required!', status => 401);
            return;
        }

        my $dbh = $conn->dbh;
        my $entries = Actub::Model::Entry::read_top($dbh);

        $self->render(entry_infos => $entries);

    } => 'post');

    $r->post('/(:name)/inbox' => sub {
        my $self = shift;

    #    print Dumper($self->req->headers);
        print $self->req->headers->header('Signature');

        my $entity = $self->req->body;
        print $entity . "\n";

        my $jj = $self->req->json;
        print Dumper($jj);

        my $dbh = $conn->dbh;
        Actub::Model::Received::insert($dbh, {
            id => $jj->{id},
            type => $jj->{type},
            entity => $entity,
        });

        if($jj->{type} eq 'Follow'){
            Actub::Followers::add($dbh, $self->param('name'), $jj->{actor});

            my $actor = $app->config('host') . '/' . $self->param('name');
            my $dbhj = DBI->connect("dbi:SQLite:dbname=actub_job.sqlite", "", "");
            Actub::Accept::enqueue($dbhj, $actor, $jj);
        } elsif($jj->{type} eq 'Undo'){
            Actub::Followers::delete($dbh, $self->param('name'), $jj->{actor});
        }

        $self->render(text => "OK");
    });

    $r->get('/(:name)/outbox' => sub {
        my $self = shift;

        my $json = JSON::PP->new;
        $json = $json->convert_blessed(1);

        my $top = $app->config('host') . '/' . $self->param('name');

        my $dbh = $conn->dbh;
        my $entries = Actub::Model::Entry::read_all($dbh);

        my $outbox = Actub::Outbox::make($top, $entries);
        my $out = $json->encode($outbox);

        $self->render(text => $out, format => 'as');

    });

    $r->get('/(:name)/followers' => sub {
        my $self = shift;

        my $json = JSON::PP->new;
        $json = $json->convert_blessed(1);

        my $top = 'https://actub.ub32.org/argrath';

        my $followers = Actub::Followers::make($top, [
            'https://pawoo.net/users/argrath',
            'https://mstdn.jp/users/argrath',
            ]);
        my $out =  $json->encode($followers);

        $self->render(text => $out, format => 'as');

    });

    $r->get('/(:name)/(:id)' => sub {
        my $self = shift;

        my $dbh = $conn->dbh;
        my $entry = Actub::Model::Entry::read_row($dbh, $self->param('id'));

        $self->render(e => $entry);

    } => 'entry');

    # server

    $r->get('/.well-known/host-meta' => sub {
        my $c = shift;
        $c->stash(host => $app->config('host'));
        $c->render(template => 'hostmeta', format => 'xml', handler => 'ep');
    });

    $r->get('/.well-known/webfinger' => sub {
        my $c = shift;
        my $id = $c->param('resource');
        $id =~ s/^acct://;
        $id =~ s/@.*//;
        my $accept = $c->req->headers->accept // '';
        print "accept: $accept\n";
        print "webfinger: $id\n";
        $c->stash(
            domain => $app->config('domain'),
            host => $app->config('host'),
            );
        $c->stash(id => $id);
        my $form = 'json';
        if($accept eq 'application/xrd+xml'){
            $form = 'xml';
        }
        $c->render(template => 'webfinger', format => $form, handler => 'ep');
    });

    $self->helper(datetime => sub {
        my ($self, $arg) = @_;
        return POSIX::strftime "%Y/%m/%d %H:%M:%S", localtime($arg);
    });
}


# sub

sub is_user {
    my ($user, $users) = @_;
    return defined $users->{$user};
}

sub auth {
    my ($header, $users) = @_;
    if (!defined $header){return 0;}
    my ($user, $pass) = split /:/, $header;
    my $u = $users->{$user};
    if(!defined $u){return 0;}
    my $p = $u->{pass};
    if(!defined $p){return 0;}
    return $p eq $pass;
}

sub is_ap {
    my $arg = shift // '';
    my (@params) = split /,/, $arg;

    for(@params){
        s/^ +//;
        s/ +$//;
        print $_ . "\n";
        if($_ eq 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"' ||
           $_ eq 'application/activity+json'){ return 1; }
    }
    return 0;
}

1;
