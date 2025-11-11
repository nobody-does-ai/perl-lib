package Nobody::Redact;
use common::sense;
use autodie;
our($STDOUT,$STDERR);
our(%red);
our($re);
use Nobody::Util qw(croak class ppx safe_can eex);
our($fileno);
#    BEGIN { say fileno(STDOUT); };
#    BEGIN { $fileno=\&CORE::fileno; };
#    BEGIN {
#      sub OUR_fileno(*) {
#        $DB::single=1;
#      };
#    };
#    BEGIN { eex $CORE::{fileno},\&CORE::fileno; *CORE::fileno=\&OUT_fileno; };
#    BEGIN { say $fileno };
BEGIN {
  open($STDERR,">&STDERR");
  open($STDOUT,">&STDOUT");
}
sub TIEHANDLE {
  $STDERR->say(ppx($_[1]));
  my $class = class(shift);
  my $fh=shift;
  die "not an IO Handle" unless $fh->can("write");
  die "not an IO Handle" unless $fh->can("print");
  die "not an IO Handle" unless $fh->can("printf");
  my $self={fh=>$fh,fd=>fileno($fh),@_};
  bless($self,$class);
}
sub FILENO {
  my($self)=shift;
  $DB::single=1;
  my($fd)=$self->{fd};
  $fd;
};
sub PRINT {
  my $self = shift;
  my $buf = join(defined $, ? $, : "",@_);
  $buf .= $\ if defined $\;
  $self->WRITE($buf,length($buf),0);
}

sub PRINTF {
  my $self = shift;

    my $buf = sprintf(shift,@_);
    $self->WRITE($buf,length($buf),0);
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
  } else {
    croak ref($self)," doesn't define a GETC method";
  }
}

sub READ {
  my $pkg = ref $_[0];
  croak "$pkg doesn't define a READ method";
}

sub WRITE {
  our(%self);
  local(*self)=shift;
  my $text = shift;
  my $tlen = shift;
  my $toff = shift;
  $STDERR->say(ppx({
  self=>\%self,
  text=>\$text,
  tlen=>\$tlen,
  toff=>\$toff
    }));
}

sub CLOSE {
  my $pkg = ref $_[0];
  croak "$pkg doesn't define a CLOSE method";
}

1;
sub WRITE
{
  my($self)=shift;
  my $fd = $self->{fd};
  my $buf="$_[1]";
  my $len="$_[2]";
  my $off="$_[3]";
  $STDERR->say(ppx({fd=>$fd,buf=>$buf,len=>$len,off=>$off}));
  return syswrite($fd,$buf,$len,$off);
}
sub add {
  my (%new)=map { $_, "*"x(length($_)) } @_;
  $red{$_}=$red{$_} for sort keys %new;
  ($re)=map { qr{$_} } join('',
    '(',
    join('|',keys %red),
    ')'
  );
};
BEGIN {
  tie *STDOUT, __PACKAGE__, *STDOUT;
}
unless(caller){
  package main;
  use common::sense;
  say fileno(*STDOUT);
  Nobody::Redact::add("test","this");
  syswrite(STDOUT,"test\n");
  STDOUT->say("this is a test this is only a test\n");
  STDOUT->say("this is a test this is only a test\n");
  STDOUT->say("this is a test this is only a test\n");
};
1;
