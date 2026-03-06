use AnyEvent::ReadLine::Gnu;
use Tie::Handle;

package Handle::Redir;
require Tie::Handle;

our(@ISA) = qw(Tie::StdHandle);
sub TIEHANDLE {
  my $pkg = shift;
  if (defined &{"{$pkg}::new"}) {
    warnings::warnif("WARNING: calling ${pkg}->new since ${pkg}->TIEHANDLE is missing");
    $pkg->new(@_);
  }
  else {
    croak "$pkg doesn't define a TIEHANDLE method";
  }
}

sub PRINT {
  my $self = shift;
  if($self->can('WRITE') != \&WRITE) {
    my $buf = join(defined $, ? $, : "",@_);
    $buf .= $\ if defined $\;
    $self->WRITE($buf,length($buf),0);
  }
  else {
    croak ref($self)," doesn't define a PRINT method";
  }
}

sub PRINTF {
  my $self = shift;

  if($self->can('WRITE') != \&WRITE) {
    my $buf = sprintf(shift,@_);
    $self->WRITE($buf,length($buf),0);
  }
  else {
    croak ref($self)," doesn't define a PRINTF method";
  }
}

sub READLINE {
  my $pkg = ref $_[0];
  croak "$pkg doesn't define a READLINE method";
}

sub GETC {
  my $self = shift;

  if($self->can('READ') != \&READ) {
    my $buf;
    $self->READ($buf,1);
    return $buf;
  }
  else {
    croak ref($self)," doesn't define a GETC method";
  }
}

sub READ {
  my $pkg = ref $_[0];
  croak "$pkg doesn't define a READ method";
}

sub WRITE {
  my $pkg = ref $_[0];
  croak "$pkg doesn't define a WRITE method";
}

sub CLOSE {
  my $pkg = ref $_[0];
  croak "$pkg doesn't define a CLOSE method";
}

1;

sub READ { ... }		# Provide a needed method
sub TIEHANDLE { ... }	# Overrides inherited method

# asynchronously print something
my $t = AE::timer 1, 1, sub {
  $rl->hide;
  print "async message 1\n"; # mind the \n
  $rl->show;

  # the same, but shorter:
  $rl->print ("async message 2\n");
};

# do other eventy stuff...
AE::cv->recv;
