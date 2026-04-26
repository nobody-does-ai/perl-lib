package Nobody::JSON;
use FindBin qw($RealBin);
use lib "$RealBin/../lib", "$RealBin/lib";
use Nobody::Auto qw( common::sense JSON::XS );
use common::sense;
require Exporter;
our @ISA = qw(Exporter);
our $VERSION = '0.01';

our @EXPORT    = qw( encode_json decode_json );
our @EXPORT_OK = qw( encode_json decode_json json_encode json_decode );
our %EXPORT_TAGS = ( all => [ @EXPORT_OK ] );

use JSON::XS qw( decode_json );

# Lazy-initialised encoder configured for maximum readability:
# - ascii: escape non-ASCII so output is safe in any context
# - pretty: human-readable indented output
# - allow_nonref: encode bare scalars, not just objects/arrays
my $coder;
sub _coder { $coder //= JSON::XS->new->ascii->pretty->allow_nonref }

sub encode_json { _coder()->encode(shift) }

# Aliases matching the JSON::XS naming convention
*json_encode = \&encode_json;
*json_decode = \&decode_json;

1;

=head1 NAME

Nobody::JSON - JSON encoding with the prettiest possible output

=head1 SYNOPSIS

  use Nobody::JSON;

  my $json = encode_json({ key => "value", list => [1, 2, 3] });
  my $data = decode_json($json);

=head1 DESCRIPTION

C<Nobody::JSON> is a thin wrapper around C<JSON::XS> that configures the
encoder for maximum human readability: ASCII-safe output, pretty-printed
with indentation, and support for non-reference scalars.

The interface is intentionally compatible with C<JSON::XS>, C<JSON::PP>,
C<Cpanel::JSON::XS>, and any other JSON module that exports C<encode_json>
and C<decode_json> with the same prototypes.

=head1 EXPORTS

C<encode_json> and C<decode_json> are exported by default.
C<json_encode> and C<json_decode> are available as aliases via C<:all>
or explicit import.

=head1 FUNCTIONS

=head2 encode_json( $data )

Encodes C<$data> to a pretty-printed, ASCII-safe JSON string.

=head2 decode_json( $json )

Decodes a JSON string to a Perl data structure.  Thin pass-through to
C<JSON::XS::decode_json>.

=head1 AUTHOR

Rich Paul, C<< <nobody at cpan.org> >>

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
