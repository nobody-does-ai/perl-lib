package Tie::ArrayNoNull;
use Tie::StdArray;
my($eex);
BEGIN {
  our(@ISA)=qw( Tie::StdArray );
  require Nobody::PP;
  $eex=sub{};
#      $eex=\&Nobody::PP::eex;
  sub check {
    my($o)=@_;
    $eex->($o);
    return unless grep { !defined } @$o;
    $eex->("FAILING!");
    die "nulls in array";
  }
  sub call($$\@) {
    local(@_)=@_;
    my($o,$n,$a,$r)=@_; # result not initialized
    my($s)=Tie::StdArray->can($n);
    if(wantarray){
      $r=[ $s->($o,@$a) ];
    } else {
      $r=$s->($o,@$a);
    };
    check($a);
    return wantarray?@$r:$r;
  };
};
sub TIEARRAY {
  local(@_)=@_;
  call(shift,"TIEARRAY",@_);
};
sub SPLICE {
  local(@_)=@_;
  call(shift,"SPLICE",@_);
};
sub UNSHIFT {
  local(@_)=@_;
  call(shift,"UNSHIFT",@_);
};
sub DELETE {
  local(@_)=@_;
  call(shift,"UNSHIFT",@_);
};
1;
