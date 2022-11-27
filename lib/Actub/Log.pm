package Actub::Log;

use Exporter 'import';

our @EXPORT_OK = qw/log/;

my $logobj;

sub log {
    if($#_ > -1){
        $logobj = @_[0];
    }
    return $logobj;
}

1;
