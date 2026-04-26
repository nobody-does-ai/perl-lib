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
use POSIX::At qw(openat linkat unlinkat);

plan tests => 6;

ok(POSIX::At->can('openat'), 'openat is available');

my $tmp = "t_openat_tmp_$$.txt";

# Create a file using openat (O_CREAT | O_WRONLY)
my $fd = openat(AT_FDCWD, $tmp, O_CREAT | O_WRONLY | O_TRUNC, 0640);
ok($fd >= 0, 'openat created file and returned fd');

# Write to the fd (should call syswrite on the returned fd)
my $text = "hello via openat\n";
my $ok_write = 0;
if ($fd >= 0) {
    my $count = syswrite FD, $text, length($text)
        if open(FD, ">&$fd");
    ok($count == length($text), 'syswrite to fd from openat works');
    close FD;
    $ok_write = 1 if $count == length($text);
} else {
    fail('Could not write to fd');
}
say "system readlink $tmp";
# Reopen file read-only with openat and check contents
my $fd2 = openat(AT_FDCWD, $tmp, O_RDONLY, 0);
ok($fd2 >= 0, 'openat re-opens file for reading');
my $readback = '';
if ($fd2 >= 0) {
#      ddx({fd2=>$fd2});
    if (open(FR, "<&$fd2")) {
#          ddx( [ fileno(FR), readlink("/proc/self/fd/".fileno(FR)) ]);
        my $got = sysread FR, $readback, 1024;
#            ddx( $got );
        close FR;
#            ddx( [$readback, $text ] );
        ok($got == length($text) && $readback eq $text, 'read content matches written content');
    } else {
        fail('Could not open file handle for reading');
    }
} else {
    fail('Failed to re-open with openat');
}

mkdir("t/tmp");
#    eex("test");
open(*TMP,"t/tmp");
linkat(*TMP,"../../$tmp",AT_FDCWD,$tmp);
system "find -name $tmp";

# Clean up
ok(unlinkat(AT_FDCWD, $tmp, 0) == 0, 'unlinkat removed test file');

# End of test file.
