#!/usr/bin/perl
use Test::More tests => 2;
use lib ".";
use_ok("Make::Task");

ok(Make::Task->new);
