#!/usr/bin/env perl
use strict;
use warnings;
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
use lib ".";
use POSIX::At qw(openat AT_FDCWD unlinkat linkat);
plan tests => 9;
open(STDERR,">&STDOUT");
ok(POSIX::At->can('openat'), 'openat is available');
my ($ok)=\&ok;
*ok=sub ($;$) {
  my($res)=$ok->(@_);
  eex("ok(@_)=>$res");
  $res;
};
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
# Reopen file read-only with openat and check contents
my $fd2 = openat(AT_FDCWD, $tmp, O_RDONLY, 0);
ok($fd2 >= 0, 'openat re-opens file for reading');
my $readback = '';
if ($fd2 >= 0) {
    if (open(FR, "<&$fd2")) {
        my $got = sysread FR, $readback, 1024;
        close FR;
        ok($got == length($text) && $readback eq $text, 'read content matches written content');
    } else {
        fail('Could not open file handle for reading');
    }
} else {
    fail('Failed to re-open with openat');
}

my($tmpdir)="t/tmp";
mkdir($tmpdir);
rename($tmp,"$tmpdir/x$tmp");
my($fd3)=openat(AT_FDCWD,$tmpdir,O_RDONLY);
ok($fd3 >= 0, 'openat re-opens new dir for reading');
my($fd4)=openat($fd3,"x$tmp",O_RDONLY);
ok($fd4 >= 0, 'openat re-opens x$tmp via new dir for reading');
open(my $dir,"<&$fd3");
ok($dir, "open dir glob from dirfd");
ok(unlinkat($fd3, "x$tmp", 0) == 0, 'unlinkat removed test file');
