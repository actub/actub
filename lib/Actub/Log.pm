package Actub::Log;

use Exporter 'import';

our @EXPORT_OK = qw/logobj/;

my $log;

sub logobj {
    if($#_ > -1){
        $log = @_[0];
    }
    return $log;
}

1;
