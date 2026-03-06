package Nobody::JSON;
use common::sense;
require Exporter;
our(@ISA) = qw(Exporter);
our(@EXPORT) = ( qw( decode_json encode_json ));

use JSON::XS qw(decode_json);
our($coder);
sub json_decode;
sub json_encode;
*json_decode=*decode_json;
*json_encode=*encode_json;

sub encode_json {
 $coder //= JSON::XS->new->ascii->pretty->allow_nonref;
 return $coder->encode (shift);
};
1;
