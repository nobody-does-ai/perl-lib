#!/usr/bin/perl
# vim: ts=2 sw=2 ft=perl
use Nobody::Util;    
package Nobody::Wrapper;
sub new {
  die "usage: Nobody::Wrapper->new( \*FD, 'tmp.log' )" unless 3==(
    grep { defined } @_
  );
  my($class)=shift;
  my($self)={ hand=>shift, dst=>shift };
  open($self->{dupe},">&".fileno($self->{hand}));
  eex($self);     
};
open(STDOUT,">out");
open(STDERR,">&STDOUT");
