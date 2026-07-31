#!/usr/bin/perl
# vim: ts=2 sw=2 ft=perl
package Nobody::Path;
use Nobody::PP qw(eex);
use Nobody::Util;
BEGIN {
  eex(\%INC);
  eex(scalar(@Nobody::Util::EXPORT));
  my(%key);
  $key{$_}++for( keys %Nobody::Path:: );
};
eex( \%INC );
#use Data::Dumper;
#BEGIN { print Dumper(\%INC)."\n\n"; };
#
#use Nobody::PP qw(eex);
#use feature "say";
#use Path::Tiny qw(path);
#BEGIN {
#say "HEY";
#};
1;
