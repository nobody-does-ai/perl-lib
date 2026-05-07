#!/usr/bin/env perl
use strict;
use warnings;
use ExtUtils::MakeMaker;
use Path::Tiny;
my(@missing) = grep { !-f } map { [ split ]->[0] } qx(cat MANIFEST);
die "missing (@missing)" if @missing;

my($mf)="Makefile";
my($mf1)=path("Makefile.tmp");
sub MyWriteMakefile {
  WriteMakefile(@_);
  local(@_)=$mf1->lines;
  $mf1->remove();
  path($mf)->spew(join("","#!/usr/bin/make\n","\n",@_));
};
MyWriteMakefile(
  NAME         => 'perlmod',
  FIRST_MAKEFILE =>"$mf1",
);
