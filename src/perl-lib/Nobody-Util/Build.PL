#!/usr/bin/perl

use Module::Build;
my $build = Module::Build->new
(
	module_name => 'Nobody::Util',
	license  => 'perl',
#	requires => {
#		'perl'          => '5.6.1',
#		'Some::Module'  => '1.23',
#		'Other::Module' => '>= 1.2, != 1.5, < 2.0',
#	},
);
$build->create_build_script;
