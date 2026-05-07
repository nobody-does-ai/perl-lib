#!/usr/bin/env perl
use strict;
use warnings;
use ExtUtils::MakeMaker;
$Verbose=1;
use Path::Tiny;
my(@missing) = grep { !-f } map { [ split ]->[0] } qx(cat MANIFEST);
die "missing (@missing)" if @missing;

WriteMakefile(
  NAME         => 'perl-lib',
);
