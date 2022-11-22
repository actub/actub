package Actub::Entry;

use strict;
use warnings;

use Actub::Model::Entry;
use Actub::Enqueue;
use WWW::ActivityPub::Note;
use WWW::ActivityPub::Create;

use POSIX qw(strftime);

use Data::Dumper;


sub w3cdate {
    my $time = shift;

    return POSIX::strftime "%Y-%m-%dT%H:%M:%SZ", gmtime($time);
}

sub lid {
    my $time = shift;

    return POSIX::strftime "%Y%m%d%H%M%S", localtime($time);
}

sub make_note {
    my ($lid, $message, $time, $actor) = @_;
    my $id = sprintf '%s/%s', $actor, $lid;
    my $note = WWW::ActivityPub::Note->new(
        id => $id,
        type => 'Note',
        content => $message,
        published => w3cdate($time),
        url => $id,
        attributedTo => $actor,
        to => [
            'https://www.w3.org/ns/activitystreams#Public'
            ],
        cc => [
            $actor . '/followers'
            ],
        );
    return $note;
}

sub make_create {
    my ($note) = @_;
    my (@to) = @{$note->to};
    my (@cc) = @{$note->cc};

    my $create = WWW::ActivityPub::Create->new(
        id => $note->id . '/create',
        type => 'Create',
        actor => $note->attributedTo,
        published => $note->published,
        to => \@to,
        cc => \@cc,
        object => $note,
        );
    return $create;
}

sub make {
    my ($dbh, $message, $actor) = @_;

    my $time = time;

    my $id = lid($time);

    my $entry_infos = Actub::Model::Entry::insert($dbh, {
        id => $id,
        message => $message,
        datetime => $time,
    });

    my $note = make_note($id, $message, $time, $actor);
    my $create = make_create($note);

    $create->context('https://www.w3.org/ns/activitystreams');

    print Dumper($create);

    return $create;
}

sub enqueue {
    my ($dbh, $actor, $entry, $dbhj) = @_;

    my $followers = Actub::Model::Followers::read_all($dbh);
    my @tolist = map {$_->{actor}} @$followers;

    Actub::Enqueue::enqueue($actor, \@tolist, $entry, $dbhj);
}

1;
