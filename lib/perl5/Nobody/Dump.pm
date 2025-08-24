package Nobody::Dump;

use common::sense;
use vars qw(@EXPORT @EXPORT_OK $VERSION $DEBUG);
use subs qq(dump);
use Scalar::Util qw(blessed reftype);

require Exporter;
*import = \&Exporter::import;
@EXPORT = qw( o2pl );
sub otype {
  for(shift) {
    return "TIEOBJ" if tied($_);
    return "OBJECT" if blessed($_);
    my ($reftype)=reftype($_);
    return $reftype if defined $reftype;
    return "SCALAR";
  }
}
sub TIEOBJ {
};
sub OBJECT {
};
sub HASH {
};
sub ARRAY {
};
sub SCALAR {
};
sub CODE {
};
sub RegExp {
};
sub REF {
};
sub o2pl {
  return o2pl([@_]) unless @_==1;
  my($self)=shift;
  my ($otype)=otype($self);
  if($otype eq SCALAR) {
    return SCALAR($self);
  } else {
    return $otype($self);
  };
};
unless(caller) {
  my ($test)="test";
  say o2pl($test);
};
