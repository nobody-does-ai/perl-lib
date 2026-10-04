#!/usr/bin/perl
package main;
use Test::More;
use Nobody::Util;
require Nobody::PP;
use lib 't/lib', 'lib';
use_ok('Tie::ArrayNoNull');

sub main() {
  my($a);
  $a=Tie::ArrayNoNull->TIEARRAY;
  $a->UNSHIFT(10000);
  is("@$a","10000");
  $a->PUSH(qw( 1 2 3 4 5 ));
  is("@$a","10000 1 2 3 4 5");
  $a->DELETE(1);
  is("@$a","1 10000 1 2 3 4 5");
  my($b);
  $DB::single=1;
  $b=Tie::ArrayNoNull->TIEARRAY(@$a);;
  eval {
    $b->SPLICE(3,1,undef,undef);
  };
  is(scalar(grep m{nulls in array}, "$@"),1);
  $a->SPLICE(3,0,1,qw( 1 2 3 4 5 ));
  eval {
    $a->SPLICE(3,0,undef);
  };
  done_testing();
};
main;
