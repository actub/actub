package Actub::Controller::Edit;

use Mojo::Base 'Mojolicious::Controller';

sub newform {
    my $self = shift;
    my $app = $self->app;

    if(!auth($self->req->url->to_abs->userinfo, $app->config('users'))){
        $self->res->headers->www_authenticate('Basic');
        $self->render(text => 'Authentication required!', status => 401);
        return;
    }

    my $dbh = $app->conn->dbh;
    my $entries = Actub::Model::Entry::read_top($dbh);

    $self->render(template => 'newform', entry_infos => $entries);
}

sub create {
    my $self = shift;
    my $app = $self->app;

    my $message = $self->param('message');
    my $actor = $app->config('host') . '/' . $self->param('name');

    return $self->render(template => 'error', message => 'Please input message')
    unless $message;

    my $dbh = $app->conn->dbh;

    {
        my $create = Actub::Entry::make($dbh, $message, $actor);

        my $actor = $app->config('host') . '/' . $self->param('name');
        my $dbhj = DBI->connect("dbi:SQLite:dbname=actub_job.sqlite", "", "");
        Actub::Entry::enqueue($dbh, $actor, $create, $dbhj);
    }

    $self->redirect_to('/' . $self->param('name'));
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

1;
