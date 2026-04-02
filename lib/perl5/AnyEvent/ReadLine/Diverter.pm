package AnyEvent::ReadLine::Diverter;
use Carp qw( croak );
use AnyEvent::ReadLine::Gnu;
use Tie::Handle;
our(@ISA) = qw(Tie::StdHandle);
sub TIEHANDLE {
  my $pkg = shift;
  my $self={};
  open($self->{sink},">&".fileno(@_?shift:*STDOUT));
  bless($self,$pkg);
}
our($done);
sub FILENO {
  fileno(shift->{sink});
};
sub WRITE {
  my($self)=shift;
  if($done) {
    $self->{sink}->print(substr($_[0],$_[2],$_[1]));
  } else {
    local($done)=1;
    AnyEvent::ReadLine::Gnu->print(@_);
  };
}

BEGIN { $DB::single=1 };
use Nobody::PP @Nobody::PP;;EXPORT_OK;
#    BEGIN {
#      *eex=\&Nobody::PP::eex;
#      eex({ map { $_, fileno(*{$_}) } qw(STDIN STDOUT STDERR) });
#    };
INIT {
  tie *STDOUT, 'AnyEvent::ReadLine::Diverter', *STDOUT;
  tie *STDERR, 'AnyEvent::ReadLine::Diverter', *STDERR;
#      eex({ map { $_, fileno(*{$_}) } qw(STDIN STDOUT STDERR) });
};
1;

