#!/usr/bin/env perl
# t/07-meta.t -- fchmodat, fchownat, utimensat, futimesat, mkfifoat, mknodat
use strict;
use warnings;
use Fcntl qw(:mode O_RDONLY O_WRONLY O_CREAT O_DIRECTORY);
use POSIX qw(close);
use FFI::Platypus::Memory qw(malloc free);
use FFI::Platypus::Buffer qw(scalar_to_pointer);
use Path::Tiny qw(tempdir path);
use Fcntl qw( O_CREAT O_TRUNC );
use POSIX::At qw( AT_FDCWD opendirat openat );
use IO::Dir;

BEGIN {
  eval { require Nobody::Util; Nobody::Util->import(); 1 };
  *eex = sub { } unless defined &eex;
}

use Test::More;

my $tmp     = tempdir( CLEANUP => 1 );
my $tst = $tmp->child("test-dir")->mkdir;
my $dir = opendirat($tst);
my $dfd = fileno($dir);
my $ffd = openat($dir,"test-file.txt",O_CREAT|O_TRUNC,0700);
eex($dfd,$ffd);
done_testing();
