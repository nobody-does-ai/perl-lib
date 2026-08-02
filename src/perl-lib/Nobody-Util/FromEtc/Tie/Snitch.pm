package Tie::Snitch;
use common::sense;
use Tie::Array;
BEGIN {
  STDOUT->autoflush(1);
};
our($AUTOLOAD);
sub AUTOLOAD {
  my($pkg,$sub)=map { m{(.*)::(.*)} } $AUTOLOAD;
  #say STDERR join(":", __FILE__, __LINE__, $AUTOLOAD);
  #say STDERR "$pkg :: $sub";
  my($data);
  if(0){
  } elsif ( $sub eq 'TIESCALAR' ) {
    require Tie::StdScalar;
    my($scalar);
    tie $scalar, 'Tie::StdScalar';
    $data={imp=>tied $scalar};
    return bless($data,__PACKAGE__);
  } elsif($sub eq 'TIEARRAY') {
    require Tie::StdArray;
    my(@array);
    tie @array, 'Tie::StdArray';
    $data={imp=>tied @array};
    return bless($data,__PACKAGE__);
  } elsif ( $sub eq 'TIEHASH' ) {
    require Tie::StdHash;
    my(%hash);
    tie %hash, 'Tie::Snitch';
    $data={imp=>tied %hash};
    return bless($data,__PACKAGE__);
  } else {
    $data=shift;
    say STDERR join(":",__FILE__,__LINE__,$data->can($sub));
    return $data->{imp}->$sub(@_);
  };
  die "no return above( $pkg $sub @_ )";
};

unless(caller) {
  package main;
  our($s,@a,%h);
  tie $s,'Tie::Snitch';
#      tie @a,'Tie::Snitch';
#      tie %h,'Tie::Snitch';
#      $s="scalar";
#      push(@a,'array','array');
#      $h{key1}='value1';
#      $h{key2}='value2'; 
#      STDERR->say( \$s, \@a, \%h );
#      STDERR->say( map { $_, $a[$_] } keys @a );
#      STDERR->say( map { $_, $h{$_} } keys %h );
};
1;


