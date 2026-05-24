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
use POSIX::At qw(openat AT_FDCWD unlinkat);
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
my $fh = openat(AT_FDCWD, $tmp, O_CREAT | O_WRONLY | O_TRUNC, 0640);
isa_ok($fh, 'IO::File', 'openat created file and returned handle');

# Write to the returned handle.
my $text = "hello via openat\n";
my $count = syswrite $fh, $text, length($text);
ok($count == length($text), 'syswrite to handle from openat works');
close $fh;

# Reopen file read-only with openat and check contents
my $fh2 = openat(AT_FDCWD, $tmp, O_RDONLY, 0);
isa_ok($fh2, 'IO::File', 'openat re-opens file for reading');
my $readback = '';
my $got = sysread $fh2, $readback, 1024;
close $fh2;
ok($got == length($text) && $readback eq $text, 'read content matches written content');

my($tmpdir)="t/tmp";
mkdir($tmpdir);
rename($tmp,"$tmpdir/x$tmp");
my $dir = openat(AT_FDCWD, $tmpdir, O_RDONLY | O_DIRECTORY, 0);
isa_ok($dir, 'IO::Dir', 'openat re-opens new dir for reading');
ok(defined fileno($dir), "dir handle has a descriptor");
my $nested = openat($dir, "x$tmp", O_RDONLY, 0);
isa_ok($nested, 'IO::File', 'openat re-opens x$tmp via new dir handle');
close $nested;
ok(unlinkat($dir, "x$tmp", 0) == 0, 'unlinkat removed test file');
$dir->close;
