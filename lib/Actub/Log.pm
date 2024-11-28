package Actub::Log;

use Exporter 'import';

our @EXPORT_OK = qw/log dlog/;

my $logobj;
my $dlogobj;

sub log {
    if($#_ > -1){
        $logobj = @_[0];
    }
    return $logobj;
}

sub dlog {
    if($#_ > -1){
        $dlogobj = @_[0];
    }
    return $dlogobj;
}

1;
