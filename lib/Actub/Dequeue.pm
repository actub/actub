package Actub::Dequeue;

use Crypt::OpenSSL::RSA;

use File::Slurper 'read_text';
use JSON::PP;
use MIME::Base64;

sub get_pk {
    my $conffile = $ENV{MOJO_CONFIG} // 'actub.json';
    my $jsonfile = read_text($conffile);
    my $json = decode_json($jsonfile);
    my $users = $json->{users};
    my $user = (keys %$users)[0];

    return $users->{$user}->{private_key};
}

sub sign {
    my ($data) = shift;

    my $pk = get_pk();

    my $key = Crypt::OpenSSL::RSA->new_private_key($pk);
    $key->use_sha256_hash();
    my $s = $key->sign($data);

    return encode_base64($s, "");
}

1;
