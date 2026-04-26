#!/usr/bin/env perl
# t/07-meta.t -- fchmodat, fchownat, utimensat, futimesat, mkfifoat, mknodat
use strict;
use warnings;
use File::Temp qw(tempdir);
use Fcntl qw(:mode O_RDONLY O_WRONLY O_CREAT O_DIRECTORY);
use POSIX qw(close);
use FFI::Platypus::Memory qw(malloc free);
use FFI::Platypus::Buffer qw(scalar_to_pointer);
use POSIX::At qw(
  AT_FDCWD
  openat unlinkat fchmodat fchownat utimensat mkfifoat mknodat
);

BEGIN {
  eval { require Nobody::Util; Nobody::Util->import(); 1 };
  *eex = sub { } unless defined &eex;
}

use Test::More;

my $tmp     = tempdir( CLEANUP => 1 );
my $base_fd = openat( AT_FDCWD, $tmp, O_RDONLY | O_DIRECTORY, 0 );

sub mkfile {
  my ($fd, $name) = @_;
  my $ffd = openat($fd, $name, O_CREAT|O_WRONLY, 0644);
  close($ffd);
}

# fchmodat
mkfile($base_fd, "chmod.txt");
is( fchmodat( $base_fd, "chmod.txt", 0600, 0 ), 0, "fchmodat succeeded" );
is( (stat("$tmp/chmod.txt"))[2] & 07777, 0600, "fchmodat: mode is 0600" );

# fchownat — chown to our own uid/gid (always allowed)
my ($uid, $gid) = ($<, $( + 0);
mkfile($base_fd, "chown.txt");
is( fchownat( $base_fd, "chown.txt", $uid, $gid, 0 ), 0, "fchownat succeeded" );

# utimensat — set atime/mtime to a known epoch via packed buffer
# struct timespec[2]: (tv_sec sint64, tv_nsec sint64) x2 = 32 bytes
mkfile($base_fd, "utime.txt");
my $epoch = 1_000_000_000;
my $tsbuf = pack('l!l!l!l!', $epoch, 0, $epoch, 0);
is( utimensat( $base_fd, "utime.txt", scalar_to_pointer($tsbuf), 0 ), 0,
    "utimensat succeeded" );
is( (stat("$tmp/utime.txt"))[9], $epoch, "utimensat: mtime set correctly" );

# futimesat (deprecated; may not be present)
SKIP: {
  skip "futimesat not available on this platform", 1
    unless POSIX::At->can('futimesat') && defined &POSIX::At::futimesat;

  mkfile($base_fd, "futime.txt");
  # struct timeval[2]: (tv_sec sint64, tv_usec sint64) x2 = 32 bytes
  my $tvbuf = pack('l!l!l!l!', $epoch, 0, $epoch, 0);
  is( POSIX::At::futimesat( $base_fd, "futime.txt", scalar_to_pointer($tvbuf) ), 0,
      "futimesat succeeded" );
}

# mkfifoat
is( mkfifoat( $base_fd, "test.fifo", 0600 ), 0, "mkfifoat created named pipe" );
ok( -p "$tmp/test.fifo", "test.fifo is a named pipe" );

# mknodat — create a regular file (may need root on some kernels; skip on EPERM)
SKIP: {
  my $rc = mknodat( $base_fd, "mknod.reg", S_IFREG | 0600, 0 );
  skip "mknodat S_IFREG not permitted (EPERM)", 1
    if $rc == -1 && $! + 0 == 1;
  is( $rc, 0, "mknodat created regular file" );
}

close($base_fd);
done_testing();
