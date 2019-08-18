package WWW::ActivityPub::Base;

use strict;
use warnings;

use Class::Tiny;

sub TO_JSON {
    my %ret;
    my $self = shift;
    for (keys %$self){
        my $key = $_;
        my $jsonkey = $key;
        if($key eq 'context'){
            $jsonkey = '@context';
            if(!defined $$self{$_}){next;}
        }
        $ret{$jsonkey} = $$self{$_};
    }
    return \%ret;
}

1;