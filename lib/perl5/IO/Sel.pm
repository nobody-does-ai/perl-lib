package IO::Sel;
use common::sense;
use Nobody::Util;
use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);
require Exporter;

our $VERSION = "1.49";

our @ISA = qw(Exporter); # This is only so we can do version checking

our (@fds,$max);
{
  package IO::Sel::Wrap;
  our($rfd,$wfd,$buf);
  sub new {
    my ($class)=map { ref||$_ } shift;
    my ($self)=[];
    local($rfd,$wfd,$buf);
    *rfd=\$self->[0];
    *wfd=\$self->[1];
    *buf=\$self->[2];
  };
  sub fileno {
    my ($self)=shift;
    my ($rfd)=$self->[0];
    fileno($rfd);
  };
  sub copy {
    my($self)=shift;
    $self->write($self->read);
  };
#    
#    	       my $flags = fcntl($REMOTE, F_GETFL, 0)
#    		   or die "Can't get flags for the socket: $!\n";
#    
#    	       fcntl($REMOTE, F_SETFL, $flags | O_NONBLOCK)
#    		   or die "Can't set flags for the socket: $!\n";
  sub read {
    my ($self)=shift;
    my ($block)=$self->blocking;
    $self->blocking(0);
    
  };
  sub write {
  };
};
sub new
{
  my ($class)= map { ref || $_ } shift;
  local(@fds,$max);
  my ($self)={
    fds=>\@fds,
    max=>\$max,
  };
  bless($self,$class);
  $self->add($_) for @_;
  $self;
}
sub wrap {
  return bless
  my ($self)=shift or die "no self";
  ddx($self);
  my ($fh)=shift or die "no fh";
  ddx($fh);
  if(safe_can($fh,"fileno")){
    ddx( $fh);
    return $fh;
  } elsif(reftype($fh) eq 'array'){
    ddx( $fh);
  } else {
    die "cannot wrap ", pp($fh);
  };
};

sub add {
  local(@_)=@_;
  my ($self)=shift;
  local(@_) = map { $self->wrap($_) } @_;
  push(@_, map { @$_ } splice(@{$self->{fds}}));
  local(*fds)=$self->{fds};
  for(grep { defined($_->fileno) } @_) {
  };
};

1;
