#!/usr/bin/perl
use Test::More tests => 2;
use lib ".";
use_ok("Symbol::Slots");

open(SLOT,"<","/dev/null");
is(sysread(SLOT,$_,0,1),0);
