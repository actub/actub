package Actub::Enqueue;

use strict;
use warnings;

use Jonk;
use Encode qw(encode);
use Data::Dumper;

sub enqueue {
    my ($actor, $tolist, $entry, $dbhj) = @_;

    print Dumper($entry);

    my $jonk = Jonk->new($dbhj);

    my $json = JSON::PP->new->convert_blessed(1);

    my $entrystr = encode('UTF-8', $json->encode($entry));

    print $entrystr . "\n";

    for(@$tolist){
        print $_ . "\n";
        my $job_id = $jonk->insert('post', $actor . "\n" . $_ . "\n" . $entrystr);
     }
}

1;
