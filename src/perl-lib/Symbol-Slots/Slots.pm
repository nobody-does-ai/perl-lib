package Symbol::Slots;

require Exporter;
*import=\&Exporter::import;
use strict;
use warnings;
our $VERSION = '0.01';
our(@EXPORT)=qw(slots);
require XSLoader;
XSLoader::load('Symbol::Slots', $VERSION);

1;
__END__

=head1 NAME

Symbol::Slots - Check which typeglob slots are actually initialized.

=head1 SYNOPSIS

    use Symbol::Slots;
    my @slots = Symbol::Slots::hash(*glob);

=cut
