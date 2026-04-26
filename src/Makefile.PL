#!/usr/bin/env perl
use strict;
use warnings;
use ExtUtils::MakeMaker;
my(@missing) = grep { !-f } map { [ split ]->[0] } qx(cat MANIFEST);
die "missing (@missing)" if @missing;

WriteMakefile(
  NAME         => 'perl-lib',
);
