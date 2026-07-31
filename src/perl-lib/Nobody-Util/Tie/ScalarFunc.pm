package Tie::ScalarFunc;

use Tie::Array;

our(%self,$self);
sub TieScalar {
  my($class)=class(shift);
  local(%self);
  while(@_){
    local($_,@_)=@_;
    if(ref){
      if('HASH' eq reftype($_)){
        unshift(@_,%$_);
      } else {
        die "bad ref: ",ppx($_);
      };
    } else {
      $self{$_}=shift;
    };
  };
  die "no fetch: ".pp(\%self) unless $self{fet};
  bless(\%self,$class);
};

1
