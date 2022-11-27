package Actub::Controller::Discovery;

use Mojo::Base 'Mojolicious::Controller';

use Actub::Log qw/log/;

sub hostmeta {
    my $c = shift;
    my $app = $c->app;

    $c->stash(host => $app->config('host'));
    $c->render(template => 'hostmeta', format => 'xml', handler => 'ep');
}

sub webfinger {
    my $c = shift;
    my $app = $c->app;

    my $id = $c->param('resource');
    $id =~ s/^acct://;
    $id =~ s/@.*//;
    my $accept = $c->req->headers->accept // '';
    log->info(sprintf('finger: Accept: %s ID: %s', $accept, $id));
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
}

1;
