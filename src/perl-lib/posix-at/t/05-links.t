#!/usr/bin/env perl
# t/05-links.t -- linkat, symlinkat, readlinkat
use strict;
use warnings;
use Test::More tests => 5;
use File::Temp qw(tempdir);
use Fcntl qw(O_RDONLY O_WRONLY O_CREAT O_DIRECTORY);
use POSIX qw(close write);
use FFI::Platypus::Memory  qw(malloc free);
use FFI::Platypus::Buffer  qw(buffer_to_scalar);
use POSIX::At qw( AT_FDCWD openat unlinkat linkat symlinkat readlinkat );

BEGIN {
  eval { require Nobody::Util; Nobody::Util->import(); 1 };
  *eex = sub { } unless defined &eex;
}

my $tmp     = tempdir( CLEANUP => 1 );
my $base_fd = openat( AT_FDCWD, $tmp, O_RDONLY | O_DIRECTORY, 0 );

# Create a source file
my $ffd = openat( $base_fd, "src.txt", O_CREAT | O_WRONLY, 0644 );
write( $ffd, "data\n", 5 );
close($ffd);

# linkat
is( linkat( $base_fd, "src.txt", $base_fd, "hard.txt", 0 ), 0,
    "linkat created hard link" );
my @s = stat("$tmp/src.txt");
my @h = stat("$tmp/hard.txt");
is( $s[1], $h[1], "hard link shares inode" );

# symlinkat
is( symlinkat( "src.txt", $base_fd, "sym.txt" ), 0,
    "symlinkat created symlink" );

# readlinkat
my $ptr = malloc(256);
my $n   = readlinkat( $base_fd, "sym.txt", $ptr, 256 );
my $tgt = buffer_to_scalar( $ptr, $n );
free($ptr);
ok( $n > 0, "readlinkat returned positive byte count" );
is( $tgt, "src.txt", "readlinkat content matches symlink target" );

close($base_fd);
