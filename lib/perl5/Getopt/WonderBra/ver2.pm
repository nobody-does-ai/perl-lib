#!/usr/bin/env perl
package Getopt::WonderBra::ver2;
use strict;
use warnings;
use Carp qw(confess);
use Exporter qw(export_to_level);

our $VERSION   = '2.01';
our @EXPORT_OK = qw(getopt);

# Optional spec map, injected via import
my %SPEC;

sub import {
    my ($class, @args) = @_;
    my $spec;

    # If the LAST arg is a hashref, treat it as the spec map
    if (@args && ref($args[-1]) eq 'HASH') {
        $spec = pop @args;
    }

    # Default export: getopt
    @args = ('getopt') unless @args;
    export_to_level(1, $class, @args);

    %SPEC = $spec ? %$spec : ();
}

# -------- internal: programmer error in option spec --------

sub _fatal_spec {
    my ($msg) = @_;
    select STDERR;
    my $script = $0 // 'this script';
    print "$script: internal option spec error: $msg\n";
    print "This is not your fault as a user.\n";
    print "Please get the author to fix the getopt format string.\n";
    exit 2;
}

# -------- internal: help/version wrappers --------

sub _call_help {
    my (@msg) = @_;

    my $have_help = defined &main::help;
    if ($have_help) {
        if (@msg) {
            select STDERR;
            main::help(@msg);
            print "\nERROR: @msg\n";
            exit 1;
        } else {
            select STDOUT;
            main::help();
            exit 0;
        }
    } else {
        if (@msg) {
            select STDERR;
            print "No help() defined in main; error: @msg\n";
            exit 1;
        } else {
            select STDOUT;
            print "No help() defined in main; please add one.\n";
            exit 0;
        }
    }
}

sub _call_version {
    my () = @_;

    my $have_ver = defined &main::version;
    select STDOUT;
    if ($have_ver) {
        main::version();
    } else {
        print "No version() defined in main.\n";
    }
    exit 0;
}

# -------- parse format string into switch table --------
#   like original WonderBra: single letters, : = arg, '-' = allow long opts

sub _parse_fmt {
    my ($fmt) = @_;
    _fatal_spec("missing switch specifier format string")
        unless defined $fmt;

    my (%switches, @arg, @noarg);

    local $_ = $fmt;
    while (length) {
        my ($switch, $colons);
        ($switch, $colons, $_) = m/^(.)(:?:?)(.*)/;

        _fatal_spec('optional args ("::") not supported') if $colons eq '::';
        _fatal_spec('":" is not a legal switch')          if $switch eq ':';
        _fatal_spec("switch '$switch' repeated in format string")
            if $switches{$switch};

        if ($colons) {
            push @arg, $switch;
            $switches{$switch} = 'arg';
        } else {
            push @noarg, $switch;
            $switches{$switch} = 'noarg';
        }
    }

    # '-' in spec ⇒ accept long options, stored as 'arg' type
    $switches{'-'} = 'arg' if defined $switches{'-'};

    return \%switches;
}

# -------- spec helper: run any attached handler for this flag --------
# SPEC keys: '-m', '--manual', etc.
# Values can be:
#   * CODE     => sub { my ($flag, @vals) = @_; ... }
#   * SCALAR   => counter (increment)
#   * ARRAY    => push @vals
#   * HASH     => $hash->{$flag} = @vals>1 ? \@vals : $vals[0]
#   * HASHREF  => { hand => ..., takes => N, help => "..." }
#                 (takes defaults to 1 if switch type=arg, else 0)

sub _apply_spec {
    my ($flag, $vals_ref, $switch_type) = @_;
    return unless %SPEC;

    my $spec = $SPEC{$flag} // $SPEC{"--$flag"} // $SPEC{"-$flag"};
    return unless $spec;

    my ($hand, $takes);

    if (ref($spec) eq 'HASH' && exists $spec->{hand}) {
        $hand  = $spec->{hand};
        $takes = $spec->{takes};
    } else {
        $hand  = $spec;
        $takes = undef;
    }

    # Default "takes" based on switch type if not provided
    if (!defined $takes) {
        $takes = ($switch_type && $switch_type eq 'arg') ? 1 : 0;
    }

    my @vals = @$vals_ref;
    # takes == 0 → ignore vals; ==1 → first; >1 → pass through as-is
    if ($takes == 0) {
        @vals = ();
    } elsif ($takes == 1) {
        @vals = @vals ? ($vals[0]) : ();
    }

    if (ref($hand) eq 'CODE') {
        $hand->($flag, @vals);
    } elsif (ref($hand) eq 'SCALAR') {
        $$hand++;
    } elsif (ref($hand) eq 'ARRAY') {
        push @$hand, @vals;
    } elsif (ref($hand) eq 'HASH') {
        $hand->{$flag} = @vals > 1 ? \@vals : $vals[0];
    } else {
        # unsupported shapes are silently ignored
    }
}

# -------- public entry: getopt --------
# Single shot:
#   @ARGV = getopt("moiura", @ARGV);
# Returns:
#   (-m, -i, ... , '--', nonopts...)

sub getopt ($@) {
    my ($fmt, @argv) = @_;

    my $switches = _parse_fmt($fmt);
    my %sw       = %$switches;

    my @opts;
    my @nonopts;

    while (@argv) {
        my $a = shift @argv;

        # end of options marker
        if ($a eq '--') {
            push @nonopts, @argv;
            last;
        }

        # non-option or single '-' as argument
        if ($a !~ /^-/ || $a eq '-') {
            push @nonopts, $a;
            next;
        }

        # long option
        if ($a =~ /^--(.+)/) {
            my $long = $1;

            # always honour --help / --version
            return _call_help()    if $long eq 'help';
            return _call_version() if $long eq 'version';

            # only accept other long opts if '-' is in the format
            _call_help("not accepting long opts, but got --$long")
                unless defined $sw{'-'};

            push @opts, "--$long";

            # apply spec if any
            _apply_spec("--$long", [], 'noarg');
            next;
        }

        # short or bundled options
        $a =~ s/^-//;  # strip leading single '-'
        while (length $a) {
            my $s = substr($a, 0, 1, '');  # pop first char
            my $type = $sw{$s}
              or _call_help("illegal switch: -$s");

            push @opts, "-$s";

            if ($type eq 'noarg') {
                _apply_spec("-$s", [], $type);
                next;
            }

            # type eq 'arg': need a value
            my @vals;
            if (length $a) {
                # remainder of bundle is the value
                push @vals, $a;
                $a = '';
            } else {
                @argv or _call_help("switch -$s missing required arg");
                push @vals, shift @argv;
            }

            push @opts, @vals;
            _apply_spec("-$s", \@vals, $type);
            last;  # arg options terminate bundle
        }
    }

    return (@opts, '--', @nonopts);
}

1;
