package Tie::Poison;
sub TIESCALAR {
  my $s;
  return bless(\$s);
};
sub TIEARRAY {
  return bless([]);
};
sub TIEHASH {
  return bless({});
};
sub TIEHANDLE {
  local (*STDOUT);
  return bless(\*STDOUT);
};
my $callers=sub {
  local(@_);
  my $num=1;
  while(1){
    my (@caller)=caller($num++);
    last unless @caller;
    next if $caller[0] eq 'Tie::Poison';
    $caller[3]=$AUTOLOAD if $caller[3] eq 'Poison::AUTOLOAD';
    push(@_,join(":",splice(@caller,1,3)));
  }
  @_;
};
sub AUTOLOAD {
  my ($name) = $AUTOLOAD =~ m{::(\w+)$};
  local(@_)=(
    "$name called on poisoned object",
    $callers->(),
  );
  die pp(\@_);
};
return 1 if caller;
use Nobody::PP qw(:all);
ddx([caller]);
1;
