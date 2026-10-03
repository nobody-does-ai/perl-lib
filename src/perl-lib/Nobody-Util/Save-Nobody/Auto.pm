package Nobody::Auto;
use strict;
use warnings;

our $VERSION = '0.01';

# Nobody::Auto - auto-install missing CPAN modules at runtime.
#
# Usage:
#   use Nobody::Auto qw( JSON::PP HTTP::Tiny Some::Module );
#
# For each module listed, Nobody::Auto will:
#   1. Try to load it with require().
#   2. If that fails, shell out to cpanm --notest to install it.
#   3. Try to load it again; die if it still fails.
#
# After the first successful run everything is already installed, so
# subsequent starts are fast: require() succeeds immediately and cpanm
# is never called.

sub import {
    my ($class, @modules) = @_;

    for my $mod (@modules) {
        # Convert module name to file path (Foo::Bar -> Foo/Bar.pm)
        (my $file = $mod) =~ s{::}{/}g;
        $file .= '.pm';

        # Already loaded?
        next if $INC{$file};

        # Try loading it
        eval { require $file };
        next unless $@;  # loaded fine

        # Not found - install via cpanm
        warn "Nobody::Auto: $mod not found, installing via cpanm...\n";
        my $rc = system('cpanm', '--notest', '--quiet', $mod);
        if ($rc != 0) {
            die "Nobody::Auto: cpanm failed to install $mod (exit $rc)\n";
        }

        # Try again after install
        eval { require $file };
        if ($@) {
            die "Nobody::Auto: installed $mod but still cannot load it: $@\n";
        }

        warn "Nobody::Auto: $mod installed and loaded.\n";
    }
}

1;
