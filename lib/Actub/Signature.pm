package Actub::Signature;

use Crypt::OpenSSL::RSA;
use MIME::Base64;

sub sign {
    my ($data, $pk) = @_;

    my $key = Crypt::OpenSSL::RSA->new_private_key($pk);
    $key->use_sha256_hash();
    my $s = $key->sign($data);

    return encode_base64($s, "");
}

1;
