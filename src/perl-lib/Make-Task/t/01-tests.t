#!/usr/bin/perl
use Test::More tests => 2;
use lib "../blib/lib", "../blib/arch/auto";
use Nobody::Util;
BEGIN {
use_ok("Symbol::Slots");
};

open(SLOT,"<","/dev/null");

our(%slots);
*slots=slots(*SLOT);
eex(\%slots);
ok(ref(slots(*SLOT))eq'HASH');
