#!/usr/bin/env perl
# t/06-rename.t -- renameat, renameat2
use strict;
use warnings;
use File::Temp qw(tempdir);
use Fcntl qw(O_RDONLY O_WRONLY O_CREAT O_DIRECTORY);
use POSIX qw(close);
use POSIX::At qw( AT_FDCWD RENAME_NOREPLACE openat renameat renameat2 );

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

# renameat
mkfile($base_fd, "a.txt");
is( renameat( $base_fd, "a.txt", $base_fd, "b.txt" ), 0,
    "renameat renamed a.txt to b.txt" );
ok( -e "$tmp/b.txt" && !-e "$tmp/a.txt", "a.txt gone, b.txt present" );

# renameat2 (optional)
SKIP: {
  skip "renameat2 not available on this platform", 2
    unless POSIX::At->can('renameat2') && defined &POSIX::At::renameat2;

  mkfile($base_fd, "c.txt");
  mkfile($base_fd, "d.txt");
  # RENAME_NOREPLACE should fail when destination exists
  is( renameat2( $base_fd, "c.txt", $base_fd, "d.txt", RENAME_NOREPLACE ), -1,
      "renameat2 RENAME_NOREPLACE fails when dst exists" );
  # Should succeed when destination is absent
  is( renameat2( $base_fd, "c.txt", $base_fd, "e.txt", RENAME_NOREPLACE ), 0,
      "renameat2 RENAME_NOREPLACE succeeds when dst absent" );
}

close($base_fd);
done_testing();
