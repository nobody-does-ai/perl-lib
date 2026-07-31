#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Nobody::Util;
use FindBin qw($Dir);
BEGIN {
  use lib "$Dir";
};

use_ok('IO::PSelect') or BAIL_OUT('POSIX::At did not load');

eex(
done_testing();
