#!/usr/bin/perl
use IO::Sel;

package Test;
use Nobody::Util;
use IO::Handle;

my($sel)=IO::Sel->new();
sub new {
  my($class)=class(shift);
  my($self)={ cmd=>[@_]};
  bless($self,$class);
};
sub fileno {
  fileno(shift->{fh});
};
sub run {
  my($self)=shift;
  $self->{pid}=open($self->{fh},"-|",@{$self->{cmd}});
};
sub readline {
  my($self)=shift;
  my($fh)=$self->{fh};
  local($_)=scalar(<$fh>);
  $_;
};
sub close {
  my($self)=shift;
  my($fh)=$self->{fh};
  close($fh);
};
sub on_read {
  my($self)=shift;
  print join($,,@_);
};
package main;
use Nobody::Util;

for(0 .. 5) {

};
while($sel->handles){
  @_=$sel->can_read(1);
  for my $fh(@_) {
    local $_=$fh->readline;
    if(defined($_)){
      if($tail eq $fh) {
        say("$_");
      } else {
        say("$_"); 
      };
    } else {
      eex($fh);
      $sel->remove($fh);
      eex $fh->close;
      @test=grep { $_ ne $fh } @test;
    };
  };
};
