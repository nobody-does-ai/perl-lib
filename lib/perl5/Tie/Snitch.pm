package Tie::Snitch;
use common::sense;
use Tie::Array;
use Data::Dump ();
BEGIN {
  STDOUT->autoflush(1);
};
our($AUTOLOAD);
my(%other)=qw( pp 1 ppx 1 dd 1 ddx 1 );
sub AUTOLOAD {
  my($pkg,$sub)=map { m{(.*)::(.*)} } $AUTOLOAD;
  my($data);
  if(0){
  } elsif ($sub eq 'pp') {
    return Data::Dump::pp(@_);
  } elsif ($sub eq 'dd') {
    return Data::Dump::dd(@_);
  } elsif ($sub eq 'ddx') {
    return Data::Dump::ddx(@_);
  } elsif ( $sub eq 'TIESCALAR' ) {
    require Tie::StdScalar;
    my($scalar);
    tie $scalar, 'Tie::StdScalar';
    $data={ref=>\$scalar,imp=>tied $scalar};
    return bless($data,__PACKAGE__);
  } elsif($sub eq 'TIEARRAY') {
    require Tie::StdArray;
    my(@array);
    tie @array, 'Tie::StdArray';
    $data={ref=>\@array,imp=>tied @array};
    return bless($data,__PACKAGE__);
  } elsif ( $sub eq 'TIEHASH' ) {
    require Tie::StdHash;
    my(%hash);
    tie %hash, 'Tie::Snitch';
    $data={ref=>\%hash,imp=>tied %hash};
    return bless($data,__PACKAGE__);
  } else {
    return if $sub eq "CLEAR";
    $data=shift;
    return $data->{imp}->$sub(@_);
  };
  die "no return above( $pkg $sub @_ )";
};

unless(caller) {
  package main;
  say join(":",__FILE__,__LINE__,"msg2");
  our($s,@a,%h);
#      tie $s,'Tie::Snitch';
  tie @a,'Tie::Snitch';
  tie %h,'Tie::Snitch';
  $s="scalar";
  push(@a,'array','array');
  $h{key1}='value1';
  $h{key2}='value2'; 
  STDERR->say( \$s, \@a, \%h );
  STDERR->say( map { $_, $a[$_] } keys @a );
  STDERR->say( map { $_, $h{$_} } keys %h );
};
1;


