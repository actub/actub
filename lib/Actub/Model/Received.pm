package Actub::Model::Received;

sub read_all {
    my $dbh = shift;

    my $msgs = $dbh->selectall_arrayref(
        "SELECT id, type, entity FROM received ORDER BY id",
        { Slice => {} }
        );

    return $msgs;
}

sub insert {
    my ($dbh, $row) = @_;
    my $sth = $dbh->prepare(
        'INSERT INTO received (id, type, entity) VALUES (?, ?, ?)')
      or die $dbh->errstr;

    $sth->execute($row->{id}, $row->{type}, $row->{entity});
}

1;
