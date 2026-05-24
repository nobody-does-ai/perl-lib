#!/usr/bin/env perl
use strict;
use warnings;
use lib ".";
use Test::More;
use common::sense;
BEGIN {
  use subs qw(eex);
  if ( eval { require Nobody::Util; Nobody::Util->import(); 1 } ) {
    # eex imported from Nobody::Util
  } else {
    *eex = sub { };
  }
}
use Fcntl qw(:DEFAULT :mode);
use POSIX::At;;
use POSIX::At qw(openat unlinkat);

plan tests => 7;

ok(POSIX::At->can('openat'), 'openat is available');

my $tmp = "t_openat_tmp_$$.txt";
my $dir = "t_openat_tmp_$$.dir";

# Create a file using openat (O_CREAT | O_WRONLY)
my $fh = openat(AT_FDCWD, $tmp, O_CREAT | O_WRONLY | O_TRUNC, 0640);
isa_ok($fh, 'IO::File', 'openat created file and returned');

# Write to the returned file handle.
my $text = "hello via openat\n";
my $count = syswrite $fh, $text, length($text);
ok($count == length($text), 'syswrite to handle from openat works');
close $fh;

# Reopen file read-only with openat and check contents
my $fh2 = openat(AT_FDCWD, $tmp, O_RDONLY, 0);
isa_ok($fh2, 'IO::File', 'openat re-opens file for reading');
my $readback = '';
my $got = sysread $fh2, $readback, 1024;
close $fh2;
ok($got == length($text) && $readback eq $text, 'read content matches written content');

mkdir($dir);
my $dh = openat(AT_FDCWD, $dir, O_RDONLY | O_DIRECTORY, 0);
isa_ok($dh, 'IO::Dir', 'openat returns IO::Dir for directories');
$dh->close if $dh;
rmdir($dir);

# Clean up
ok(unlinkat(AT_FDCWD, $tmp, 0) == 0, 'unlinkat removed test file');

# End of test file.
