package Actub::Activity;

use strict;
use warnings;

use WWW::ActivityPub::Activity;
use WWW::ActivityPub::Note;

sub make {
    my ($type, $top, $note) = @_;
    my $act = WWW::ActivityPub::Activity->new;

    $act->id($note->id . '/activity');
    $act->type($type);
    $act->actor($top);
    $act->to($note->to);
    $act->cc($note->cc);
    $act->object($note);

    return $act;
}

sub make_note {
    my ($top, $entry) = @_;

    my $note = WWW::ActivityPub::Note->new;
    $note->id($top . '/' . $entry->{id});
    $note->type("Note");
#    $note->summary();
    $note->content($entry->{message});
    $note->published("2001-01-01T00:00:00Z");
    $note->attributedTo($top);
    $note->to(["https://www.w3.org/ns/activitystreams#Public"]);
    $note->cc([$top . '/followers']);

    return $note;
}
1;
