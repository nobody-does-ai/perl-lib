#!/usr/bin/perl
# vim: ts=2 sw=2 ft=perl
eval 'exec perl -x -wS $0 ${1+"$@"}'
  if 0;
$|++;

package Nobody::Pipe;
use utf8;
use open ':std', ':encoding(UTF-8)';
use common::sense;
use autodie;
use Nobody::Util;
our(@VERSION) = qw( 0 1 0 ); # Header installed by /usr/bin/mkperl

sub new {
  my($class,$self)=map { (ref($_),{%$_}), ($_,{@_})} shift; 
  bless($self,$class);
};
