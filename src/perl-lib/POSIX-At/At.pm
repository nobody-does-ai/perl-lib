#!/usr/bin/env perl
package POSIX::At;

use common::sense;
use POSIX::Structs qw( ffi
  POSIX::Structs::Stat
  POSIX::Structs::Timespec
  POSIX::Structs::Timeval
);
use Fcntl qw(:DEFAULT :mode);
use Exporter 'import';
use Carp qw( carp croak confess cluck verbose longmess shortmess );
use IO::Dir ();
use IO::File ();
use POSIX ();
use vars qw(@EXPORT @EXPORT_OK %EXPORT_TAGS);
our $VERSION = '0.01';


BEGIN {
  push(@EXPORT, qw( AT_FDCWD AT_EMPTY_PATH ));
  push(@EXPORT_OK, qw(
    AT_FDCWD AT_SYMLINK_NOFOLLOW AT_SYMLINK_FOLLOW
    AT_EACCESS AT_REMOVEDIR AT_EMPTY_PATH
    RENAME_NOREPLACE RENAME_EXCHANGE RENAME_WHITEOUT
    )
  );
  push(@EXPORT_OK, qw(
    openat     fstatat     unlinkat  mkdirat    mknodat
    mkfifoat   fchmodat    fchownat  utimensat  linkat
    symlinkat  readlinkat  renameat  renameat2  faccessat
    futimesat  opendirat
    )
  );
}

# Optional debug helper: if Nobody::Util is available (dev environment),
# import eex for annotated stderr dumps; otherwise install a no-op.
BEGIN {
  use subs qw(eex);
  if ( eval { require Nobody::Util; Nobody::Util->import(); 1 } ) {
    # eex imported from Nobody::Util
  } else {
    *eex = sub { };
  }
}

#----------------------------------------------------------------------
# Constants (from linux/fcntl.h and friends)
#----------------------------------------------------------------------

use constant {
  AT_FDCWD            => -100,
  AT_SYMLINK_NOFOLLOW => 0x100,
  AT_EACCESS          => 0x200,
  AT_REMOVEDIR        => 0x200,   # overlaps AT_EACCESS on purpose (Linux ABI)
  AT_SYMLINK_FOLLOW   => 0x400,
  AT_EMPTY_PATH       => 0x1000,

  RENAME_NOREPLACE    => 0x1,
  RENAME_EXCHANGE     => 0x2,
  RENAME_WHITEOUT     => 0x4,
};

#----------------------------------------------------------------------
# FFI bootstrap — use the shared Platypus instance from POSIX::Structs
# so that the struct types defined there are visible to our attach() calls.
#----------------------------------------------------------------------
BEGIN {
  my $ffi = POSIX::Structs::ffi();

  # dirfd: accepts a raw integer fd, an AT_FDCWD constant, a Perl glob/IO
  # reference, or any object that implements fileno().
  $ffi->custom_type( dirfd => {
    native_type    => 'int',
    perl_to_native => sub {
      my ($val) = @_;
      return $val                if !ref $val && $val =~ /^-?\d+$/;
      return $val->fileno        if eval { $val->can('fileno') };
      return fileno($val);
    },
  });

  # Map common C typedefs so we can use their names in signatures.
  eval { $ffi->type('uint'  => 'mode_t') };
  eval { $ffi->type('uint'  => 'uid_t')  };
  eval { $ffi->type('uint'  => 'gid_t')  };
  eval { $ffi->type('ulong' => 'dev_t')  };

  sub attach {
    my ($name, $args, $res) = @_;
    $ffi->attach($name, $args, $res);
  }

  #--------------------------------------------------------------------
  # Raw *at() bindings — direct libc calls, C prototypes.
  # Struct pointer arguments use the POSIX::Structs package names so
  # Platypus knows the correct layout.
  #--------------------------------------------------------------------

  # int utimensat(int dirfd, const char *pathname,
  #               const struct timespec times[2], int flags);
  # We pass a pointer to the first of two consecutive Timespec structs.
  #
  # Callers should allocate two POSIX::Structs::Timespec objects back-to-back
  # using FFI::C::Array or pass a raw opaque pointer.
  attach( utimensat => ['dirfd','string','opaque','int'] => 'int' );
  #-------------------------------------------------------------------------
  # ssize_t readlinkat(int dirfd, const char *pathname,
  #                    char *buf, size_t bufsiz);
  ##
  attach( readlinkat => ['dirfd','string','opaque','size_t'] => 'ssize_t' );
  # int openat(int dirfd, const char *pathname, int flags, mode_t mode);
  #
  # int futimesat(int dirfd, const char *pathname,
  #               const struct timeval times[2]);
  # Deprecated in favour of utimensat; silently omitted if missing.
  eval {
    attach( futimesat => ['dirfd','string','opaque'] => 'int' );
    1;
  };
  ###############################################################################
  #
  #
  attach( [ openat => '_openat' ] => ['dirfd','string','int','mode_t'] => 'int' );

  # int fstatat(int dirfd, const char *pathname, struct stat *buf, int flags);
  attach( fstatat => ['dirfd','string','stat_t','int'] => 'int' );

  # int unlinkat(int dirfd, const char *pathname, int flags);
  attach( unlinkat => ['dirfd','string','int'] => 'int' );

  # int mkdirat(int dirfd, const char *pathname, mode_t mode);
  attach( mkdirat => ['dirfd','string','mode_t'] => 'int' );

  # int mknodat(int dirfd, const char *pathname, mode_t mode, dev_t dev);
  attach( mknodat => ['dirfd','string','mode_t','dev_t'] => 'int' );

  # int mkfifoat(int dirfd, const char *pathname, mode_t mode);
  attach( mkfifoat => ['dirfd','string','mode_t'] => 'int' );

  # int fchmodat(int dirfd, const char *pathname, mode_t mode, int flags);
  attach( fchmodat => ['dirfd','string','mode_t','int'] => 'int' );

  # int fchownat(int dirfd, const char *pathname,
  #              uid_t owner, gid_t group, int flags);
  attach( fchownat => ['dirfd','string','uid_t','gid_t','int'] => 'int' );



  # int linkat(int olddirfd, const char *oldpath,
  #            int newdirfd, const char *newpath, int flags);
  attach( linkat => ['dirfd','string','dirfd','string','int'] => 'int' );

  # int symlinkat(const char *target, int newdirfd, const char *linkpath);
  attach( symlinkat => ['string','dirfd','string'] => 'int' );

  # int renameat(int olddirfd, const char *oldpath,
  #              int newdirfd, const char *newpath);
  attach( renameat => ['dirfd','string','dirfd','string'] => 'int' );

  # int renameat2(int olddirfd, const char *oldpath,
  #               int newdirfd, const char *newpath, unsigned int flags);
  # Not available on all platforms/libcs; silently omitted if missing.
  eval {
    attach( renameat2 => ['dirfd','string','dirfd','string','uint'] => 'int' );
    1;
  };

  # int faccessat(int dirfd, const char *pathname, int mode, int flags);
  # Note: third arg is an access-mode bitmask (R_OK/W_OK/X_OK/F_OK), not a fd.
  attach( faccessat => ['dirfd','string','int','int'] => 'int' );

}

# openat($dirfd, $name, $flags, $mode) -> IO::File|IO::Dir|undef
#
# libc openat returns a raw file descriptor.  The public Perl API returns an
# owning handle instead; the dirfd custom type above accepts those handles for
# subsequent *at() calls via fileno().
use constant O_DIRECTORY => 0200000;
sub _fdopen_mode {
  my ($flags) = @_;
  my $accmode = $flags & O_ACCMODE;

  return ($accmode == O_RDWR)
    ? (($flags & O_APPEND) ? 'a+' : 'r+')
    : ($accmode == O_WRONLY)
      ? (($flags & O_APPEND) ? 'a' : 'w')
      : 'r';
}

sub openat {
  my ($dirfd, $name, $flags, $mode) = @_;
  $mode //= 0;

  my $fd = _openat($dirfd, $name, $flags, $mode);
  return undef if $fd < 0;

  my @st = POSIX::fstat($fd);
  unless (@st) {
    my $err = $!;
    POSIX::close($fd);
    $! = $err;
    return undef;
  }

  if (S_ISDIR($st[2])) {
    my $dh = IO::Dir->new("/proc/self/fd/$fd");
    my $err = $!;
    POSIX::close($fd);
    unless ($dh) {
      $! = $err;
      return undef;
    }
    return $dh;
  }

  my $fh = IO::File->new_from_fd($fd, _fdopen_mode($flags));
  unless ($fh) {
    my $err = $!;
    POSIX::close($fd);
    $! = $err;
    return undef;
  }

  return $fh;
}

# opendirat($dirfd, $name) -> IO::Dir
# opendirat($path) -> IO::Dir
#
# In list context this returns the same IO::Dir twice so older callers that
# split the result into "fd" and "dirhandle" slots still have a usable dirfd.
sub opendirat {
  my ($dirfd, $name) = @_;
  ($dirfd, $name) = (AT_FDCWD, $dirfd) unless defined $name;

  my $dh = openat($dirfd, $name, Fcntl::O_RDONLY() | O_DIRECTORY, 0);
  croak "opendirat $name: $!" unless defined $dh;
  croak "opendirat $name: not a directory" unless eval { $dh->isa('IO::Dir') };

  return wantarray ? ($dh, $dh) : $dh;
}

BEGIN {
  $EXPORT_TAGS{all}=[@EXPORT_OK];
  use Exporter 'import';
};
1;

__END__

=head1 NAME

POSIX::At - FFI bindings to the POSIX *at() family of filesystem syscalls

=head1 SYNOPSIS

  use POSIX::At qw(
    AT_FDCWD AT_REMOVEDIR
    openat unlinkat mkdirat
  );
  use POSIX::Structs qw( POSIX::Structs::Stat );
  use Fcntl qw(O_RDONLY O_CREAT O_WRONLY O_DIRECTORY);

  # Open a directory handle; *at calls accept it anywhere a dirfd is needed.
  my $dir = openat(AT_FDCWD, "/some/base", O_RDONLY|O_DIRECTORY, 0)
    or die "openat: $!";

  # Stat a file relative to that directory
  my $st = POSIX::Structs::Stat->new;
  fstatat($dir, "foo.txt", $st, 0) == 0
    or die "fstatat: $!";
  printf "mode=0%o size=%d\n", $st->st_mode & 07777, $st->st_size;

  # Unlink relative to that directory
  unlinkat($dir, "old.txt", 0) == 0
    or die "unlinkat: $!";

=head1 DESCRIPTION

POSIX::At provides thin FFI bindings to the modern POSIX/Linux C<*at()>
family of filesystem syscalls via L<FFI::Platypus>.

Struct arguments (e.g. for C<fstatat>) use types defined in
L<POSIX::Structs>, which must be loaded separately.  Both modules share
a single L<FFI::Platypus> instance via C<POSIX::Structs::ffi()>.

The bindings mostly follow C semantics intentionally:

=over 4

=item * C<openat> returns an C<IO::File> or C<IO::Dir> object on success,
or C<undef> on error; check C<$!> for the reason.

=item * Other functions return -1 on error; check C<$!> for the reason.

=item * No exception throwing.

=back

=head1 EXPORTS

By default: C<AT_FDCWD>, C<AT_EMPTY_PATH>.

The following may be imported by name:

  # Constants
  AT_FDCWD AT_SYMLINK_NOFOLLOW AT_SYMLINK_FOLLOW
  AT_EACCESS AT_REMOVEDIR AT_EMPTY_PATH
  RENAME_NOREPLACE RENAME_EXCHANGE RENAME_WHITEOUT

  # Bindings and helpers
  openat fstatat unlinkat mkdirat mknodat mkfifoat
  fchmodat fchownat utimensat linkat symlinkat readlinkat
  renameat renameat2 faccessat futimesat opendirat

C<renameat2> and C<futimesat> are silently absent on platforms where the
underlying libc does not provide them.

=head1 NOTES ON utimensat AND futimesat

These functions take a pointer to an array of two C<struct timespec> (or
C<struct timeval>) values.  The caller is responsible for allocating the
buffer.  The simplest approach is to use L<FFI::Platypus::Memory>:

  use FFI::Platypus::Memory qw(malloc free);
  use FFI::Platypus::Buffer qw(scalar_to_pointer);

  # Pack two struct timespec values (tv_sec, tv_nsec each sint64)
  my $buf = pack('q!q!q!q!', $sec, 0, $sec, 0);
  utimensat($dirfd, "file", scalar_to_pointer($buf), 0);

=head1 DEVELOPMENT

Set C<$ENV{VIM_TESTING}=1> before running tests to merge STDERR into STDOUT,
which makes all output appear in Vim's quickfix buffer when running C<make test>
from inside the editor.

=head1 AUTHORS

Nobody E<lt>nobody@turing-trust.comE<gt>

Claude E<lt>claude@turing-trust.comE<gt>

ChatGPT E<lt>gpt@turing-trust.comE<gt>

=head1 LICENSE

This module is free software; you may redistribute it and/or modify it
under the same terms as Perl itself.

=cut
