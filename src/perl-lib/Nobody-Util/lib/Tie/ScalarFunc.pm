package Tie::ScalarFunc;
use Nobody::Util;

sub TIESCALAR {
  my($class)=shift;
  my($self) = { fetch=>shift, store=>shift };
  bless($self,$class);
};
sub STORE {
  my($self)=shift;
  $self->{store}->(@_);
};
sub FETCH {
  my($self)=shift;
  $self->{fetch}->();
};

unless(caller) {
  package main;
  use Nobody::Util;
  my($num);
  my($tmp)=[];
  my($store)=sub {
    die "!args" unless @_;
    $tmp=[] unless ref($tmp) eq 'ARRAY';
    push(@$tmp,@_);
  };
  my($fetch)=sub {
    die "args" if @_;
    $tmp=[] unless ref($tmp) eq 'ARRAY';
    my($tmp2)=splice(@{$tmp},int(rand(@{$tmp})),1);
    $tmp2;
  };
  tie $num, 'Tie::ScalarFunc', $fetch, $store;
  my($x)=1;
  while($x<10) {
    $num=$_ for $x, $x*10, $x*20+$x;
    ++$x;
  };
  eex(scalar(@{$tmp}));
  eex(scalar(@{$tmp}));
};

1
