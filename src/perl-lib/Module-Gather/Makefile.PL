use 5.008003;
use strict;
use warnings;
use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
    NAME             => 'Module::Gather',
    AUTHOR           => ['Rich Paul <rpaul@cpan.org>'],
    VERSION_FROM     => 'Module/Gather.pm',
    ABSTRACT_FROM    => 'Module/Gather.pm', 
);

WriteMakefile(%WriteMakefileArgs);
