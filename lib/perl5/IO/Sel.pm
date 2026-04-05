package IO::Sel;
use IO::Select;
use Nobody::Util;
use Carp::Always;
our(@ISA)=qw(IO::Select);
sub stack {
#      my($lvl)=0;
#      local(@_);
#      my(@stack);
#      say STDERR __FILE__,":",__LINE__,":stack";
#      my($func,$pkg);
#      while(1) {
#        my @frame=caller($lvl);
#        splice(@frame,4);
#        $func=pop(@frame);
#        ++$lvl;
#        next if $lvl==1;
#        push(@frame,shift(@frame));
#        eex( @frame, "$func called from @frame" );
#        say STDERR join(":",@frame,$func);
#        push(@stack,[@frame]);
#      };
#      eex({lvl=>$lvl,stack=>scalar(@stack)});
#      1;
  "";
};
sub _fileno {
  use strict;
  my($self, $f) = @_;
  return unless defined $f;
  return $f->fileno if(ref($f) and $f->can("fileno"));

  $f = $f->[0] if ref $f eq 'ARRAY';
  if ($f =~ /^[0-9]+$/) {
    return $f;
  }
  elsif (defined(my $fd = fileno $f)) {
    return $fd;
  }
  else {
    foreach my $i (2 .. $self->$#*) {
      return $i - 2 if defined $self->[$i] and $self->[$i] == $f;
    }
    return undef;
  }
}
