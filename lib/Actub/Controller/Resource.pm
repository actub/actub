package Actub::Controller::Resource;

use Mojo::Base 'Mojolicious::Controller';

sub actor {
    my $self = shift;
    my $app = $self->app;
    my $actor = $app->config('host') . '/' . $self->param('name');

    my $name = $self->param('name');
    my $accept = $self->req->headers->accept // '';
    $app->log->info($accept, $name);
    if(!is_user($name, $app->config('users'))){
        $self->reply->not_found;
        return;
    }
    $self->stash(
        domain => $app->config('domain'),
        host => $app->config('host'),
        id => $self->param('name'),
        );
    if(is_ap($accept)){
        my $users = $app->config('users');
        my $actorobj = Actub::Actor::make($actor, $users->{$name});
        my $json = $app->json;
        my $out = $json->encode($actorobj);
        $self->render(text => $out, format => 'as');
    } else {
        my $dbh = $app->conn->dbh;
        my $entries = Actub::Model::Entry::read_top($dbh);
        $self->render(template => 'index', entries => $entries);
    }
}

sub entry {
    my $self = shift;
    my $app = $self->app;
    my $actor = $app->config('host') . '/' . $self->param('name');

    my $dbh = $app->conn->dbh;
    my $entry = Actub::Model::Entry::read_row($dbh, $self->param('id'));
    $entry->{actor} = $actor;

    if(is_ap($self->req->headers->accept)){
        my $json = $app->json;
        my $note = Actub::Entry::make_note(
            $entry->{id}, $entry->{message}, $entry->{datetime}, $entry->{actor});
        $note->{context} = 'https://www.w3.org/ns/activitystreams';
        my $out = $json->encode($note);
        $self->render(text => $out, format => 'as');
    } else {
        $self->render(template => 'entry', e => $entry);
    }
}

sub followers {
    my $self = shift;
    my $app = $self->app;
    my $json = $app->json;
    my $dbh = $app->conn->dbh;

    my $actor = $app->config('host') . '/' . $self->param('name');

    my $followerslist = Actub::Model::Followers::read_all($dbh);
    my (@actorslist) = map {$_->{actor}} @$followerslist;

    my $followers = Actub::Followers::make($actor, \@actorslist);
    my $out =  $json->encode($followers);

    $self->render(text => $out, format => 'as');
}

sub outbox {
    my $self = shift;
    my $app = $self->app;
    my $json = $app->json;

    my $top = $app->config('host') . '/' . $self->param('name');

    my $dbh = $app->conn->dbh;
    my $entries = Actub::Model::Entry::read_all($dbh);

    my $outbox = Actub::Outbox::make($top, $entries);
    my $out = $json->encode($outbox);

    $self->render(text => $out, format => 'as');
}

sub is_user {
    my ($user, $users) = @_;
    return defined $users->{$user};
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
