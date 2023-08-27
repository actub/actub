package Actub::Controller::Receive;

use Mojo::Base 'Mojolicious::Controller';

use Actub::Log qw/log/;

sub inbox {
    my $self = shift;
    my $app = $self->app;
    my $entity = $self->req->body;
    my $jj = $self->req->json;
    my $dbh = $app->conn->dbh;

    log->info(sprintf('Inbox: ID:%s Actor:%s Type:%s',
        $jj->{id}, $jj->{actor}, $jj->{type}));
    log->debug($entity);

    if($jj->{type} eq 'Follow'){
        log->info($entity);
        Actub::Followers::add($dbh, $self->param('name'), $jj->{actor});

        my $actor = $app->config('host') . '/' . $self->param('name');
        my $dbhj = $app->jobconn->dbh;
        Actub::Accept::enqueue($dbhj, $actor, $jj);
    } elsif($jj->{type} eq 'Undo'){
        log->info($entity);
        if($jj->{object}->{type} eq 'Follow'){
            Actub::Followers::delete($dbh, $self->param('name'), $jj->{actor});
        }
    }

    if($jj->{type} ne 'Delete'){
        Actub::Model::Received::insert($dbh, {
            id => $jj->{id},
            type => $jj->{type},
            entity => $entity,
        });
    }

    $self->render(text => "OK");
}

1;
