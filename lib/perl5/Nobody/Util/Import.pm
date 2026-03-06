#!/usr/bin/perl
# vim: ts=2 sw=2 ft=perl
#
use common::sense;
package Nobody::Util::Import;
push(@Nobody::Util::ISA,__PACKAGE__);
package Nobody::Util;
use Nobody::PP;
our(@ISA);
our(@EXPORT);
BEGIN {
  local($_,@_);
  use vars ( 
    qw( @carp %PACK @EXPORT  @EXPORT_OK  @ISA %seen)
  );
  our(%PACK, @subs);
  @subs=qw(
  QX            WNOHANG      avg       class     
  deparse       dirname      file_id   flatten   
  getcwd        getfds       getfl     lcmp      
  lsort         matrix       max       maybeRef  
  methods       methods_via  min       mkdir_p   
  pasteLines    nonblock     open_fds  mkref     
  safe_blessed  safe_isa     serdate   path      
  serial_maker  setfl        spit      spit_fh   
  stdin_sub     stdout_sub   suck      suckdir   
  sum           uniq         vcmp      vsort     
  basename      sum          avg       max       
  min           mkdir_p      suckdir   getcwd    
  pasteLines    serdate      class     mkref     
  open_fds      deparse      maybeRef           
  file_id       WNOHANG      uniq      matrix    
  dirname       capture      safe_can child_wait
  safe_isa      
  );
  {
    my %subs;
    %subs = map { $_, undef } @subs;
    @subs=keys %subs;
  };
  @subs = sort { (length($a)<=>length($b)) or ($a cmp $b) } @subs;
  my ($row)=@subs/4;
  my ($k)=0;
  my (@l);
  for(my $j=0;$j<4;$j++) {
    my ($len)=0;
    for(my $i=0;$i<$row;$i++) {
      my ($v)=$subs[$k];
      next unless defined $v;
      $len=length($v);
      ++$k;
      $l[$j][$i]=$v;
    };
    my ($pad)=( ' 'x$len);
    for(my $i=0;$i<$row;$i++) {
      for($l[$j][$i]){
          $_=substr("$_$pad",0,$len);
      };
      $_=$l[$j];
      @{$_} = grep { /\S/ } @{$_};
    };
  };
  use subs @subs;
  push(@EXPORT,@subs);
  our(@carp);
  @carp=qw( carp confess croak cluck );
  $PACK{'Carp'}=[@carp];
  $PACK{'Env'}=[qw( $HOME $PWD @PATH )];
  $PACK{'Fcntl'}=[qw(:seek :mode)];
  $PACK{'FindBin'}='EXPORT_OK';
  $PACK{'Nobody::PP'}="EXPORT_OK subs";
  $PACK{'Path::Tiny'}=undef;
  $PACK{'POSIX'}=[qw(strftime mktime :sys_wait_h )];
  $PACK{'Tie::LoudArray'};
  $PACK{'File::stat'}=[ qw( :FIELDS) ];
  for(qw( List::Util Scalar::Util Sub::Util )) {
    $PACK{$_}='EXPORT_OK';
  };
}
BEGIN {
  for(sort keys %PACK) {
    eval "use $_;";
  };
};
BEGIN {
  my (@log);
  for my $key(sort keys %PACK) {
    die unless length($key);
    my ($val)=$PACK{$key};
    my (%log)=( key=>$key, val=>$val );
    push(@log,\%log);
    if(ref($val)){
      for( "use $key qw( @{$PACK{$key}} );" ) {
        $log{eval}=$_;
        $log{list}=[ @{$PACK{$key}} ];
        eval;
        warn "$@" if "$@";
      }
    } elsif(defined($val)) {
      local(@_)=map { split } $val;
      for(@_){
        my $expr=join('','@',$key,'::',$_) ;
        $log{eval}=$expr;
        my @val=eval $expr;
        unless($key eq "Sub::Util") {
          @val = grep { $_ ne 'set_prototype' } @val;
        };
        $log{list}=[ @val ];
        push(@EXPORT, @val);
        for( "use $key qw( @val )" ) {
          my (%sym);
          for(keys %Nobody::Util::) {
            $sym{$_}//=0;
            $sym{$_}--;
          };
          eval;
          warn "$@" if "$@";
          for(keys %Nobody::Util::) {
            $sym{$_}//=0;
            $sym{$_}++;
          };
          for(keys %sym) {
            unless($sym{$_}) {
              delete $sym{$_};
            };
          };
        };
      };
    };
  };
  @EXPORT_OK= List::Util::uniq( sort @EXPORT_OK);
  @EXPORT   = List::Util::uniq( sort @EXPORT   );
};
BEGIN {
  sub FILTER {
    grep {!m{prototype|all|uniq}} @_;
  };
  use base qw( Exporter );
};
package Nobody::Util::Import;
our(@ISA);
close(DATA);
1;
__DATA__

BEGIN {
  my ($test);
  $test=q{ %s("%s test") };
  for(qw( cluck confess croak carp )) {
    eval sprintf $test,$_,$_;
  };
};
