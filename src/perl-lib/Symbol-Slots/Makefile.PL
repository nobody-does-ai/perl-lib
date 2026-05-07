use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Symbol::Slots',
    VERSION_FROM      => 'Slots.pm', 
    PREREQ_PM         => { 'Test::More' => 0 },
    ABSTRACT_FROM     => 'Slots.pm',
    AUTHOR            => 'Rich Paul <paulr@cpan.org>',
    DEFINE            => '', 
    INC               => '-I.', 
);
