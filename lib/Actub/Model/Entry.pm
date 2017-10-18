package Actub::Model::Entry;

use Encode qw/encode decode/;

sub read_row {
    my ($dbh, $id) = @_;

    my $msg = $dbh->selectrow_hashref(
        "SELECT id, message, datetime FROM entry WHERE id = ?",
        { Slice => {} },
        $id
        );

    return $msg;
}

sub read_all {
    my $dbh = shift;

    my $msgs = $dbh->selectall_arrayref(
        "SELECT id, message, datetime FROM entry ORDER BY id",
        { Slice => {} }
        );

    return $msgs;
}

sub read_top {
    my $dbh = shift;

    my $msgs = $dbh->selectall_arrayref(
        "SELECT id, message, datetime FROM entry ORDER BY id DESC LIMIT 20",
        { Slice => {} }
        );

    return $msgs;
}

sub insert {
    my ($dbh, $col) = @_;
    my $sth = $dbh->prepare(
        'INSERT INTO entry (id, message, datetime) VALUES (?, ?, ?)')
      or die $dbh->errstr;

    $sth->execute($col->{id}, $col->{message}, $col->{datetime});
}

1;
