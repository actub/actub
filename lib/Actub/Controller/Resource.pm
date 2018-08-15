package Actub::Controller::Resource;

use Mojo::Base 'Mojolicious::Controller';

sub actor {
    my $self = shift;
    my $app = $self->app;

    my $name = $self->param('name');
    my $accept = $self->req->headers->accept // '';
    print "accept: $accept\n";
    print "self: $name\n";
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
        my $u = $users->{$name};
        my $actor = Actub::Actor::make($app->config('host') . '/' . $name, $u);
        my $json = JSON::PP->new;
        $json = $json->convert_blessed(1);
        my $out =  $json->encode($actor);
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

    my $dbh = $app->conn->dbh;
    my $entry = Actub::Model::Entry::read_row($dbh, $self->param('id'));

    $self->render(template => 'entry', e => $entry);
}

sub followers {
    my $self = shift;
    my $app = $self->app;
    my $json = $app->json;

    my $top = 'https://actub.ub32.org/argrath';

    my $followers = Actub::Followers::make($top, [
        'https://pawoo.net/users/argrath',
        'https://mstdn.jp/users/argrath',
        ]);
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