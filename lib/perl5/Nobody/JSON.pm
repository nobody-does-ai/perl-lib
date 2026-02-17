package Nobody::JSON;
use common::sense;
require Exporter;
BEGIN {
  require JSON::PP;
};
BEGIN {
  our($coder);
  sub coder {
    $coder //= JSON::PP->new->ascii->pretty->allow_nonref->convert_blessed;
  };
  sub encode_json($) {
    coder()->encode(shift);
  };
  sub decode_json($) {
    coder()->decode(shift);
  };
};
BEGIN {
  require JSON::XS;
  require Nobody::PP;
}
our(@ISA) = qw(Exporter);
our(@EXPORT) = ( qw( decode_json encode_json ));

our($coder);
sub json_decode($);
*json_decode=*decode_json;
*json_encode=*encode_json;
sub decode_json($) {
 my ($coder)=coder;
 return $coder->encode (shift);
};
sub encode_json($) {
 my ($coder)=coder;
 return $coder->encode (shift);
};
1;
