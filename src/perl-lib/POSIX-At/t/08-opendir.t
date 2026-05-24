#!/usr/bin/env perl
# t/07-meta.t -- fchmodat, fchownat, utimensat, futimesat, mkfifoat, mknodat
use strict;
use warnings;
use Fcntl qw(:mode O_RDONLY O_WRONLY O_CREAT O_DIRECTORY);
use Path::Tiny qw(tempdir path);
use Fcntl qw( O_TRUNC );
use POSIX::At qw( AT_FDCWD opendirat openat );

BEGIN {
  eval { require Nobody::Util; Nobody::Util->import(); 1 };
  *eex = sub { } unless defined &eex;
}

use Test::More;

my $tmp     = tempdir( CLEANUP => 1 );
my $tst = $tmp->child("test-dir")->mkdir;
my $dir = opendirat($tst);
isa_ok($dir, 'IO::Dir', 'opendirat returns an IO::Dir');
my $dfd = fileno($dir);
ok(defined $dfd, 'opendirat handle has a file descriptor');
my $ffd = openat($dir,"test-file.txt",O_CREAT|O_WRONLY|O_TRUNC,0700);
isa_ok($ffd, 'IO::File', 'openat accepts an IO::Dir dirfd');
close($ffd);
$dir->close;
done_testing();
