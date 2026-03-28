package AnyEvent::ReadLine::Diverter;
use Carp qw( croak );
use AnyEvent::ReadLine::Gnu;
use Tie::Handle;
use Nobody::Util;

our(@ISA) = qw(Tie::StdHandle);
sub TIEHANDLE {
  my $pkg = shift;
  my $self={};
  open($self->{sink},">&".fileno(@_?shift:*STDOUT));
  bless($self,$pkg);
}
our($done);
sub WRITE {
  my($self)=shift;
  if($done) {
    $self->{sink}->print(substr($_[0],$_[2],$_[1]));
  } else {
    local($done)=1;
    AnyEvent::ReadLine::Gnu->print(pp(\@_));
  };
}

tie *STDOUT, 'AnyEvent::ReadLine::Diverter', *STDOUT;
tie *STDERR, 'AnyEvent::ReadLine::Diverter', *STDERR;
1;

