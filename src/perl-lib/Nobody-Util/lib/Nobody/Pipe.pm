#!/usr/bin/perl
# vim: ts=2 sw=2 ft=perl
eval 'exec perl -x -wS $0 ${1+"$@"}'
  if 0;
$|++;

use Nobody::Util;
package Nobody::Pipe;
use Nobody::Util;
our(@VERSION) = qw( 0 1 0 ); # Header installed by /usr/bin/mkperl

sub new {
  my($class,$self)=(shift,[@_]);
  bless($self,$class);
};
sub run {
	my($self)=shift;
	my(@pipe)=@{$self};
	for(@pipe) {
		say;
	};
};

unless(caller){
	package main;
	my($pipe)=Nobody::Pipe->new(
		"find -type f",
		"sed 's,[/], ,g'",
		"xargs printf '%s\\n'"
	);
	eex([@{$pipe}]);
	say for @{$pipe};

	for(@{$pipe}) {
		my($cmd)="$_";
		system("$cmd");
	};
};
