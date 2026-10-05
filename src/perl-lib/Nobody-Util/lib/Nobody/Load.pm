use FindBin;
use strict;
package Nobody::Load;
use feature qw( say state );
my(@vars,@subs,@envs);
BEGIN {
  push(@vars, @envs=qw( @PATH @PERL5LIB @MANPATH $PWD ));
  push(@vars, qw( @INC @EXPORT @EXPORT_OK @PATH %PKG ));
  push(@vars, qw( @HIST $dst $pkg @sym %dat )); 
  push(@subs, qw( import ));
}
BEGIN {
#      $Exporter::Verbose=1;
  use Env @envs;
  use vars @vars;
  use subs @subs;
};
BEGIN {
  push(@EXPORT, @vars, @subs);
}
BEGIN {
  use autodie;
  require Nobody::PP ;
  require Nobody::Util;
  Nobody::PP->import('eex','pp');
  sub import {
    ($dst,$pkg,@sym)=(@{[caller(0)]}[0],@_);
    @sym=@sym||(@EXPORT,@EXPORT_OK);
    require Import::Into;
    common::sense->import::into($dst);
    autodie->import::into($dst);
    Nobody::PP->import::into($dst);
    Nobody::Util->import::into($dst);
  };
};
sub get_exports {
  state($code);
  $code//=join( "", qw( package $_[0]; [@EXPORT],[@EXPORT_OK] ) );
  eval($code);
};
sub add_exports(@){
  local($_,@_)=@_;
  push(@{($PKG{$_}//=[])},qw());
  sub add_pkg($;$) {
    my($name)=shift;
    require($name);
  };
}
sub colon_pkg {
  join("::",split(m{/|.pm$}));
};
sub slash_pkg {
  join("/",split(m{::})).".pm";
};
sub load {
  my($pkg)=shift;
  for(@_) {
    require "".slash_pkg($_);
    $_->import;
  }
};
BEGIN {
  my($fmt)=q{*%s::%s=\&%s::%s}.";\n";
  sub cp {
    my($dpkg,$did,$spkg,$sid)=@_;
    $sid//=$did;
    $spkg//=([caller]->[0]);
    for(sprintf($fmt,$dpkg,$did,$spkg,$sid) ){
      next if defined eval;
      die "\n\nerror: (@{[qquote($@)]})\n\nprocessing: (@{[qquote($@)]})\n\n";
    };
  };
}
1;
