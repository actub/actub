package Actub::Activity;

use strict;
use warnings;

use WWW::ActivityPub::Activity;
use WWW::ActivityPub::Note;

use Actub::Entry;

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

    return Actub::Entry::make_note(
        $entry->{id}, $entry->{message}, $entry->{datetime}, $top);
}
1;
