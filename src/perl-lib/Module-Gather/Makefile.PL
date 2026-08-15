use 5.008003;
use strict;
use warnings;
use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
    NAME             => 'Module::Gather',
    AUTHOR           => ['Rich Paul <rpaul@cpan.org>'],
    VERSION_FROM     => 'Module/Gather.pm',
    ABSTRACT_FROM    => 'Module/Gather.pm',
    LICENSE          => 'artistic_2',
        #'Foo::Bar::Module' => '5.0401',
        'Path::Tiny' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
delete $WriteMakefileArgs{LICENSE}
    unless eval { ExtUtils::MakeMaker->VERSION('6.31'); 1 };

WriteMakefile(%WriteMakefileArgs);
