#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use lib ".";

use_ok('POSIX::At') or BAIL_OUT('POSIX::At did not load');

# constants should exist
ok(defined(&POSIX::At::AT_FDCWD), 'AT_FDCWD constant is defined');

# openat should exist on any reasonably modern Unix
if (POSIX::At->can('openat')) {
    pass('openat symbol is available');

    eval {
        require Fcntl;
        my $tmp = "t_basic_tmp_$$.txt";
        my $fd  = POSIX::At::openat(
            POSIX::At::AT_FDCWD(),
            $tmp,
            Fcntl::O_CREAT() | Fcntl::O_WRONLY() | Fcntl::O_TRUNC(),
            0644,
        );
        ok($fd >= 0, 'openat returned a non-negative fd');

        # clean up
        POSIX::At::unlinkat(POSIX::At::AT_FDCWD(), $tmp, 0);
        1;
    } or do {
        fail("openat basic test died: $@");
    };
} else {
    diag('openat not available on this platform; skipping functional test');
}

done_testing();
