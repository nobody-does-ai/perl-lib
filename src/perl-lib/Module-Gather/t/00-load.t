#!perl
use 5.008003;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Module::Gather' ) || print "Bail out!\n";
}

diag( "Testing Module::Gather $Module::Gather::VERSION, Perl $], $^X" );
