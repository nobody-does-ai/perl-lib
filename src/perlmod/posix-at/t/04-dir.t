#!/usr/bin/env perl
# t/04-dir.t -- mkdirat, fstatat, faccessat
use strict;
use warnings;
use Test::More tests => 4;
use File::Temp qw(tempdir);
use File::Spec;
use POSIX qw(S_ISDIR close);
use Fcntl qw(O_RDONLY O_DIRECTORY);
use POSIX::Structs;
use POSIX::At qw( AT_FDCWD openat mkdirat fstatat faccessat );

BEGIN {
  eval { require Nobody::Util; Nobody::Util->import(); 1 };
  *eex = sub { } unless defined &eex;
}

use constant { F_OK => 0, R_OK => 4, X_OK => 1 };

my $tmp     = tempdir( CLEANUP => 1 );
my $base_fd = openat( AT_FDCWD, $tmp, O_RDONLY | O_DIRECTORY, 0 );

# mkdirat
is( mkdirat( $base_fd, "testdir", 0755 ), 0, "mkdirat created testdir" );

# fstatat
my $st = POSIX::Structs::Stat->new;
is( fstatat( $base_fd, "testdir", $st, 0 ), 0, "fstatat on testdir succeeded" );
ok( S_ISDIR( $st->st_mode ), "fstatat: st_mode indicates directory" );

# faccessat
is( faccessat( $base_fd, "testdir", R_OK | X_OK, 0 ), 0, "faccessat R_OK|X_OK on testdir" );

close($base_fd);
