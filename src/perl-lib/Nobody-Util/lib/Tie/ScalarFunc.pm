package Tie::ScalarFunc;
use Nobody::Util;

sub TIESCALAR {
  my($class,$fetch,$store)=@_;
  my(%self) = { fetch=>shift, store=>$store };
  bless(\%self,$class);
};
sub FETCH {
  my($self)=shift;
  $self->{fetch}();
};

1
