package Actub::Model::Followers;

sub read_all {
    my $dbh = shift;

    my $msgs = $dbh->selectall_arrayref(
        "SELECT num, actor FROM followers ORDER BY num",
        { Slice => {} }
        );

    return $msgs;
}

sub read_user {
    my ($dbh, $user) = @_;

    my $msgs = $dbh->selectall_arrayref(
        "SELECT actor FROM followers WHERE user = ?",
        { Slice => {} },
        $user
        );

    return $msgs;
}

sub insert {
    my ($dbh, $row) = @_;
    my $sth = $dbh->prepare(
        'INSERT INTO followers (user, actor) VALUES (?, ?)')
      or die $dbh->errstr;

    $sth->execute($row->{user}, $row->{actor});
}

sub delete {
    my ($dbh, $row) = @_;
    my $sth = $dbh->prepare(
        'DELETE FROM followers WHERE user = ? AND actor = ?')
      or die $dbh->errstr;

    $sth->execute($row->{user}, $row->{actor});
}

1;
