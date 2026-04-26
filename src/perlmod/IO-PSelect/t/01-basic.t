#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use lib ".";

use_ok('IO::PSelect') or BAIL_OUT('POSIX::At did not load');

done_testing();
