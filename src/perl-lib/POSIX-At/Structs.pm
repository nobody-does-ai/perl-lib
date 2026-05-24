package POSIX::Structs;

use common::sense;
use FFI::Platypus 2.00;
use FFI::C;
use Exporter 'import';
use vars qw(@EXPORT_OK);

our $VERSION = '0.01';

# A shared Platypus instance.  All struct types are registered against it.
# Modules that need to attach additional functions (e.g. POSIX::At) should
# call POSIX::Structs::ffi() to obtain this instance rather than creating
# their own, so that the struct types are visible to their attach() calls.
my $ffi = FFI::Platypus->new( api => 1, lib => undef );
FFI::C->ffi($ffi);

push @EXPORT_OK, qw( ffi );
sub ffi { $ffi }

# ---------------------------------------------------------------------------
# POSIX::Structs::Timespec  —  struct timespec  (16 bytes, x86_64 Linux)
#   tv_sec  : sint64  offset 0
#   tv_nsec : sint64  offset 8
# ---------------------------------------------------------------------------
package POSIX::Structs::Timespec {
  FFI::C->struct( timespec_t => [
    tv_sec  => 'sint64',
    tv_nsec => 'sint64',
  ]);
}
push @POSIX::Structs::EXPORT_OK, 'POSIX::Structs::Timespec';

# ---------------------------------------------------------------------------
# POSIX::Structs::Timeval  —  struct timeval  (16 bytes, x86_64 Linux)
#   tv_sec  : sint64  offset 0
#   tv_usec : sint64  offset 8
# ---------------------------------------------------------------------------
package POSIX::Structs::Timeval {
  FFI::C->struct( timeval_t => [
    tv_sec  => 'sint64',
    tv_usec => 'sint64',
  ]);
}
push @POSIX::Structs::EXPORT_OK, 'POSIX::Structs::Timeval';

# ---------------------------------------------------------------------------
# POSIX::Structs::Stat  —  struct stat  (144 bytes, x86_64 Linux)
#   st_dev        : uint64  offset 0
#   st_ino        : uint64  offset 8
#   st_nlink      : uint64  offset 16
#   st_mode       : uint32  offset 24
#   st_uid        : uint32  offset 28
#   st_gid        : uint32  offset 32
#   _pad0         : uint32  offset 36  (alignment padding before st_rdev)
#   st_rdev       : uint64  offset 40
#   st_size       : sint64  offset 48
#   st_blksize    : sint64  offset 56
#   st_blocks     : sint64  offset 64
#   st_atime      : sint64  offset 72
#   st_atime_nsec : sint64  offset 80
#   st_mtime      : sint64  offset 88
#   st_mtime_nsec : sint64  offset 96
#   st_ctime      : sint64  offset 104
#   st_ctime_nsec : sint64  offset 112
#   _unused[3]    : sint64  offsets 120, 128, 136
# ---------------------------------------------------------------------------
package POSIX::Structs::Stat {
  FFI::C->struct( stat_t => [
    st_dev        => 'uint64',
    st_ino        => 'uint64',
    st_nlink      => 'uint64',
    st_mode       => 'uint32',
    st_uid        => 'uint32',
    st_gid        => 'uint32',
    _pad0         => 'uint32',
    st_rdev       => 'uint64',
    st_size       => 'sint64',
    st_blksize    => 'sint64',
    st_blocks     => 'sint64',
    st_atime      => 'sint64',
    st_atime_nsec => 'sint64',
    st_mtime      => 'sint64',
    st_mtime_nsec => 'sint64',
    st_ctime      => 'sint64',
    st_ctime_nsec => 'sint64',
    _unused1      => 'sint64',
    _unused2      => 'sint64',
    _unused3      => 'sint64',
  ]);
}
push @POSIX::Structs::EXPORT_OK, 'POSIX::Structs::Stat';

# ---------------------------------------------------------------------------
# POSIX::Structs::Dirent  —  struct dirent  (variable; d_name fixed at 256)
#   d_ino    : uint64  offset 0
#   d_off    : sint64  offset 8
#   d_reclen : uint16  offset 16
#   d_type   : uint8   offset 18
#   d_name   : string  offset 19  (256 bytes incl. NUL)
# ---------------------------------------------------------------------------
package POSIX::Structs::Dirent {
  FFI::C->struct( dirent_t => [
    d_ino    => 'uint64',
    d_off    => 'sint64',
    d_reclen => 'uint16',
    d_type   => 'uint8',
    d_name   => 'string(256)',
  ]);
}
push @POSIX::Structs::EXPORT_OK, 'POSIX::Structs::Dirent';

# ---------------------------------------------------------------------------
# POSIX::Structs::Iovec  —  struct iovec  (16 bytes, x86_64 Linux)
#   iov_base : opaque  offset 0  (void *)
#   iov_len  : size_t  offset 8
# ---------------------------------------------------------------------------
package POSIX::Structs::Iovec {
  FFI::C->struct( iovec_t => [
    iov_base => 'opaque',
    iov_len  => 'size_t',
  ]);
}
push @POSIX::Structs::EXPORT_OK, 'POSIX::Structs::Iovec';

# ---------------------------------------------------------------------------
# POSIX::Structs::Flock  —  struct flock  (32 bytes, x86_64 Linux)
#   l_type   : sint16  offset 0
#   l_whence : sint16  offset 2
#   _pad     : uint32  offset 4   (alignment before l_start)
#   l_start  : sint64  offset 8
#   l_len    : sint64  offset 16
#   l_pid    : sint32  offset 24
# ---------------------------------------------------------------------------
package POSIX::Structs::Flock {
  FFI::C->struct( flock_t => [
    l_type   => 'sint16',
    l_whence => 'sint16',
    _pad     => 'uint32',
    l_start  => 'sint64',
    l_len    => 'sint64',
    l_pid    => 'sint32',
  ]);
}
push @POSIX::Structs::EXPORT_OK, 'POSIX::Structs::Flock';

package POSIX::Structs;

1;

__END__

=head1 NAME

POSIX::Structs - FFI::C definitions of common POSIX/Linux structs

=head1 SYNOPSIS

  use POSIX::Structs qw( POSIX::Structs::Stat POSIX::Structs::Timespec );

  my $st = POSIX::Structs::Stat->new;
  fstatat($dirfd, "file", $st, 0);
  printf "mode=0%o  size=%d\n", $st->st_mode & 07777, $st->st_size;

  my $ts = POSIX::Structs::Timespec->new;
  $ts->tv_sec(1_000_000_000);
  $ts->tv_nsec(0);

=head1 DESCRIPTION

POSIX::Structs provides L<FFI::C> struct definitions for the common C
structs used by POSIX and Linux syscalls.  All layouts are for
x86_64 Linux; other architectures are not currently supported.

The following packages are defined and may be imported by name:

=over 4

=item C<POSIX::Structs::Stat>      — C<struct stat>

=item C<POSIX::Structs::Timespec>  — C<struct timespec>

=item C<POSIX::Structs::Timeval>   — C<struct timeval>

=item C<POSIX::Structs::Dirent>    — C<struct dirent> (d_name fixed at 256 bytes)

=item C<POSIX::Structs::Iovec>     — C<struct iovec>

=item C<POSIX::Structs::Flock>     — C<struct flock>

=back

The shared L<FFI::Platypus> instance used to define these types is
accessible via C<POSIX::Structs::ffi()>.  Modules that need to attach
additional functions should use this instance so that the struct types
are visible to their C<attach()> calls.

=head1 PORTABILITY

The struct layouts are hard-coded for x86_64 Linux.  Contributions
for other architectures are welcome.

=head1 AUTHORS

Nobody E<lt>nobody@turing-trust.comE<gt>

=head1 LICENSE

This module is free software; you may redistribute it and/or modify it
under the same terms as Perl itself.

=cut
