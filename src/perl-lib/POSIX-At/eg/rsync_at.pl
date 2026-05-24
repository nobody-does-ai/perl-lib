#!/usr/bin/env perl
# rsync_at.pl — recursive copy using POSIX::At *at() syscalls
use strict;
use warnings;
use POSIX::At qw(
  AT_FDCWD AT_SYMLINK_NOFOLLOW
  openat opendirat mkdirat readlinkat symlinkat fchmodat utimensat
);
use Fcntl qw( O_RDONLY O_WRONLY O_CREAT O_TRUNC );
use Path::Tiny;

sub copy_tree {
  my ($src_fd, $dst_fd, $indent) = @_;
  $indent //= 0;

  my $dh = opendirat($src_fd, '.');
  my $src_fileno = fileno($src_fd);

  while (my $name = readdir($dh)) {
    next if $name eq '.' || $name eq '..';

    lstat("/proc/self/fd/$src_fileno/$name")
      or die "lstat $name: $!";
    my $mode = (stat(_))[2];

    printf "%s%s\n", "  " x $indent, $name;

    if ( -l _ ) {
      my $buf = "\0" x 4096;
      use Nobody::Util;
      eex($src_fd,$name,$buf,4096);
      my $len = readlinkat($src_fd, $name, $buf, 4096);
      die "readlinkat $name: $!" if $len < 0;
      symlinkat(substr($buf, 0, $len), $dst_fd, $name) == 0
        or die "symlinkat $name: $!";
    }
    elsif ( -d _ ) {
      mkdirat($dst_fd, $name, $mode & 07777) == 0
        or die "mkdirat $name: $!";

      my $sub_src_fd = opendirat($src_fd, $name);
      my $sub_dst_fd = opendirat($dst_fd, $name);

      copy_tree($sub_src_fd, $sub_dst_fd, $indent + 1);

      $sub_src_fd->close;
      $sub_dst_fd->close;

      # restore dir timestamps after populating it
      _copy_times($dst_fd, $name);
      fchmodat($dst_fd, $name, $mode & 07777, 0);
    }
    else {
      my $src_file = openat($src_fd, $name, O_RDONLY, 0);
      die "openat src/$name: $!" unless defined $src_file;
      my $dst_file = openat($dst_fd, $name, O_WRONLY | O_CREAT | O_TRUNC, $mode & 07777);
      die "openat dst/$name: $!" unless defined $dst_file;

      my $buf;
      while (my $n = sysread($src_file, $buf, 65536)) {
        syswrite($dst_file, $buf, $n) == $n or die "syswrite $name: $!";
      }
      close($src_file); close($dst_file);

      _copy_times($dst_fd, $name);
      fchmodat($dst_fd, $name, $mode & 07777, AT_SYMLINK_NOFOLLOW);
    }
  }
  closedir($dh);
}

# Copy atime+mtime from the last lstat() onto dst/$name.
# struct timespec[2] = { {tv_sec,tv_nsec}, {tv_sec,tv_nsec} }, each field int64.
sub _copy_times {
  my ($dirfd, $name) = @_;
  my @st  = stat(_);
  my $buf = pack("q4", $st[8], 0, $st[9], 0);   # atime, mtime (no nsec from Perl stat)
  utimensat($dirfd, $name, $buf, AT_SYMLINK_NOFOLLOW);
}

#----------------------------------------------------------------------
my $src_fd = opendirat(AT_FDCWD, "/home/nn/src");
my $dst_fd = opendirat(AT_FDCWD, path("/home/nn/dst")->mkdir);

copy_tree($src_fd, $dst_fd);

$src_fd->close;
$dst_fd->close;
