package Actub::Controller::Receive;

use Mojo::Base 'Mojolicious::Controller';

use Actub::Log qw/log/;

sub inbox {
    my $self = shift;
    my $app = $self->app;
    my $entity = $self->req->body;
    my $jj = $self->req->json;
    my $dbh = $app->conn->dbh;

    log->info(sprintf('Inbox: ID:%s Content:%s Type:%s',
        $jj->{id}, $self->req->headers->content_type, $jj->{type}));
    log->debug($entity);

    if($jj->{type} eq 'Follow'){
        log->info($entity);
        Actub::Followers::add($dbh, $self->param('name'), $jj->{actor});

        my $actor = $app->config('host') . '/' . $self->param('name');
        my $dbhj = $app->jobconn->dbh;
        Actub::Accept::enqueue($dbhj, $actor, $jj);
    } elsif($jj->{type} eq 'Undo'){
        log->info($entity);
        Actub::Followers::delete($dbh, $self->param('name'), $jj->{actor});
    }

    $self->render(text => "OK");
}

1;
