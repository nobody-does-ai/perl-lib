#!/usr/bin/perl
# vim: ts=2 sw=2 ft=perl
#
package Nobody::Util;
local($_);
use Nobody::Util::Import;
use strict;
use warnings;
no warnings 'experimental::builtin';
use common::sense;
use Path::Tiny;
sub open_fds(;$);
BEGIN {
  sub open_fds(;$) {
    my ($dn) = "/proc/self/fd/";
    if(@_ && $_[0]) {
      map { $_, readlink "$dn$_" } open_fds();
    } else {
      opendir(my $dir,$dn);
      my $no = fileno($dir);
      grep { $_ ne '.' && $_ ne '..' && ($no-$_) } readdir($dir);
    }
  };
  sub getcwd {
    return readlink("/proc/self/cwd");
  };
};
sub getfl(*) {
  my($fh)=shift;
  my($val);
  fcntl($fh,F_GETFL,$val);
  return $val;
};
sub setfl(*$) {
  my ($fh)=shift;
  my ($val)=shift;
  fcntl($fh,F_SETFL,$val);
};
sub nonblock {
  my ($fh)=shift;
  if(!@_ || shift) {
    setfl($fh,getfl($fh)|O_NONBLOCK);
  };
};
sub getfds();
BEGIN {
  sub getfds() {
    local(@_);
    opendir(my $dir,"/proc/self/fd");
    my $no = fileno($dir);
    while(readdir($dir)){
      push(@_,$_);
    };
    closedir($dir);
    return @_;
  };
};
{
  package Path::Tiny;
  sub inode($) {
    return [shift->stat]->[1];
  };
};
sub safe_isa {
  my ($self)=shift;
  my ($class)=shift;
  return undef unless ref($self);
  return $self->isa($class);
};
sub safe_blessed {
  my ($self)=shift;
  return undef unless ref($self);
  return blessed($self);
};
sub safe_can {
  my($self)=shift;
  my($meth)=shift;
  return undef unless safe_blessed($self);
  return $self->can($meth);
};
sub child_wait {
  my ($kid);
  do {
    $kid=waitpid(0,0);
    say STDERR "$kid returned $?" if $kid>1 and $?;
  } while( $kid>1 );
};
sub file_id {
  die "useless use of file_id in void context" unless defined wantarray;
  local ($_)=shift;
  $_=path($_) unless ref($_);
  $_->stat;
  my $file_id=sprintf("%016x:%016x",$st_dev,$st_ino);
  return $file_id;
};
{
  package Null;
};
sub flatten(@);
sub flatten(@){
  return map { flatten($_) } @_ unless @_==1;
  local($_)=shift;
  return flatten(@$_) if reftype($_) eq 'ARRAY';
  return $_;
}
sub class($){
  return ref||$_||'undef' for shift;
};
sub pasteLines(@) {
  for(join("",@_)){
    s{\\\n?$}{}sm;
  }
  return join("\n",@_) unless wantarray;
  return @_;
}
sub uri {
  eval 'require URI';
  die "$@" if "$@";
  return URI->new($_);
};
sub maybeRef($) {
  carp "use class, not maybeRef";
  goto \&class;
};
sub vcmp {
  my ($a,$b) = (
    @_ == 2 ? (shift,shift) :
    @_ ? (undef, undef, warn "Warning:  vcmp wants 2 args or none") :
    ($a,$b)
  );

  my (@a)=split m{(\D+)}, $a;
  my (@b)=split m{(\D+)}, $b;
  no warnings;
  while( @a and @b and $a[0] eq $b[0] ) {
    shift @a;
    shift @b;
  };
  return 0 unless @a or @b;
  return @a <=> @b unless @a and @b;
  return $a[0] <=> $b[0] || $a[0] cmp $b[0];  
};
sub vsort {
  return sort { vcmp } @_;
};
sub lsort {
  my (@s,@l) = splice(@_);
  for(0 .. -1+@s) {
    push(@l,length);
  };
};
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
my @x=qw(sec min hour mday mon year wday yday isdst);
sub serdate(;$)
{
  my $time=@_ ? $_[0] : time;
  return strftime("%Y%m%d-%H%M%S", gmtime($time));
}
our(%caller);
sub deparse {
  eval "use B::Deparse";
  die "$@" if "$@";
  my $deparse = B::Deparse->new("-p", "-sC");
  return join(' ', 'sub{', $deparse->coderef2text(\&func), '}');
};
sub serial_maker(%) {
  my (%arg)=%{$_[0]};
  ddx(\%arg);
  my ($fmt)=$arg{fmt}//die "format is required";
  my ($max)=$arg{max}//1000;
  my ($min)=$arg{min}//0;
  my ($dir)=!!$arg{dir};
  my ($num)=$min;
  return sub {
    local($_);
    my (%res)=( fh=>undef, fn=>undef );
    for(;;){
      return undef if($num>=$max);
      $res{fn}=path(sprintf($fmt,$num));
      $res{fn}->parent->mkdir;
      ddx(\%res);
      no autodie qw(sysopen mkdir);
      if($dir) {
        if(mkdir($res{fn})){
          return \%res;
        } elsif ( $!{EEXIST} ) {
          ++$num;
        } else {
          confess "mkdir:$res{fn}:$!";
        };
      } else {
        if(sysopen($res{fh},$res{fn},Fcntl::O_CREAT|Fcntl::O_EXCL())){
          eex(\%res);
          return \%res 
        } elsif ( $!{EEXIST} ) {
          ++$num;
        } else {
          confess "sysopen:$res{fn}:$!";
        };
      }
    };
  };
};


sub methods;
sub methods_via;
sub print_methods {
  require mro;
  ddx( methods ( ref($_[0]) ) );
};

use vars qw(%seen);

sub methods {

    # Figure out the class - either this is the class or it's a reference
    # to something blessed into that class.
    my $class = shift;
    $class = ref $class if ref $class;

    local %seen;

    # Show the methods that this class has.
    methods_via( $class, '', 1 );

    # Show the methods that UNIVERSAL has.
    methods_via( 'UNIVERSAL', 'UNIVERSAL', 0 );
} ## end sub methods

=head2 C<methods_via($class, $prefix, $crawl_upward)>

C<methods_via> does the work of crawling up the C<@ISA> tree and reporting
all the parent class methods. C<$class> is the name of the next class to
try; C<$prefix> is the message prefix, which gets built up as we go up the
C<@ISA> tree to show parentage; C<$crawl_upward> is 1 if we should try to go
higher in the C<@ISA> tree, 0 if we should stop.

=cut

sub methods_via {

    # If we've processed this class already, just quit.
    my $class = shift;
    return if $seen{$class}++;

    # This is a package that is contributing the methods we're about to print.
    my $prefix  = shift;
    my $prepend = $prefix ? "via $prefix: " : '';
    my @to_print;

    # Extract from all the symbols in this class.
    my $class_ref = do { no strict "refs"; \%{$class . '::'} };
    while (my ($name, $glob) = each %$class_ref) {
        # references directly in the symbol table are Proxy Constant
        # Subroutines, and are by their very nature defined
        # Otherwise, check if the thing is a typeglob, and if it is, it decays
        # to a subroutine reference, which can be tested by defined.
        # $glob might also be the value -1  (from sub foo;)
        # or (say) '$$' (from sub foo ($$);)
        # \$glob will be SCALAR in both cases.
        if ((ref $glob || ($glob && ref \$glob eq 'GLOB' && defined &$glob))
            && !$seen{$name}++) {
            push @to_print, "$prepend$name\n";
        }
    }

    {
        local $\ = '';
        local $, = '';
        print $_ foreach sort @to_print;
    }

    # If the $crawl_upward argument is false, just quit here.
    return unless shift;

    # $crawl_upward true: keep going up the tree.
    # Find all the classes this one is a subclass of.
    my $class_ISA_ref = do { no strict "refs"; \@{"${class}::ISA"} };
    for my $name ( @$class_ISA_ref ) {

        # Set up the new prefix.
        $prepend = $prefix ? $prefix . " -> $name" : $name;

        # Crawl up the tree and keep trying to crawl up.
        methods_via( $name, $prepend, 1 );
    }
} ## end sub methods_via
1;
=head1 NAME

Nobody::Util - Pretty printing of data structures

=head1 SYNOPSIS

This is a Lazy Bastard package that you probably don't want to use.
Nobody made it because Nobody is as lazy as he is.  It's full of
ugly hacks, but saves him time.

=cut
1;
