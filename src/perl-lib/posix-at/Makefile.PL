#!/usr/bin/env perl
use strict;
use warnings;
use ExtUtils::MakeMaker;
my(@missing) = grep { !-f } map { split } qx(cat MANIFEST);
die "missing @missing" if @missing;

WriteMakefile(
  NAME         => 'POSIX::At',
  VERSION_FROM => 'At.pm',
  ABSTRACT     => 'FFI bindings to the POSIX *at() family of filesystem syscalls',
  AUTHOR       => 'Nobody <nobody@turing-trust.com>',
  LICENSE      => 'perl',

  PREREQ_PM => {
    'FFI::Platypus' => '2.00',
    'Fcntl'         => 0,
  },

  BUILD_REQUIRES => {
    'Test::More'    => 0,
    # Nobody::Util is a soft build-time dep: used for debug output (eex/ddx)
    # during development.  Not on CPAN yet; guarded with eval{} in source.
    # 'Nobody::Util' => 0,
  },

  META_MERGE => {
    resources => {
      repository => 'https://gitlab.com/PopeNobody/posix-at',
    },
  },
);
