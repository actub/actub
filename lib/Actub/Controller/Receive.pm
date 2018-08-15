package Actub::Controller::Receive;

use Mojo::Base 'Mojolicious::Controller';

sub inbox {
    my $self = shift;
    my $app = $self->app;

    my $entity = $self->req->body;
    print $entity . "\n";

    my $jj = $self->req->json;

    my $dbh = $app->conn->dbh;
    Actub::Model::Received::insert($dbh, {
        id => $jj->{id},
        type => $jj->{type},
        entity => $entity,
    });

    if($jj->{type} eq 'Follow'){
        Actub::Followers::add($dbh, $self->param('name'), $jj->{actor});

        my $actor = $app->config('host') . '/' . $self->param('name');
        my $dbhj = $app->jobconn->dbh;
        Actub::Accept::enqueue($dbhj, $actor, $jj);
    } elsif($jj->{type} eq 'Undo'){
        Actub::Followers::delete($dbh, $self->param('name'), $jj->{actor});
    }

    $self->render(text => "OK");
}

1;
