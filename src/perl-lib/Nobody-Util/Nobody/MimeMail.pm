package Nobody::MimeMail;
use Nobody::Util;
{
  use File::MMagic;
  my($magic)=File::MMagic->new;
  sub Path::Tiny::mime {
    return $magic->checktype_filename(shift);
  }
};
{
  use LWP::MediaTypes qw(media_suffix);
  sub Path::Tiny::ext {
    local($_);
    $_=media_suffix(shift->mime);
    $_;
  };
};
use Digest::MD5;
use Date::Parse qw(str2time);
sub re_ext {
  my($orig)=path(join("",shift));
  my($self)=join("",$orig);
  my($ext)=shift;
  $ext=".$ext" if length($ext);
  eex($orig,$self,$ext);
  while(1) {
    my($old)=substr($self,-length($ext));
    last unless $old eq $ext;
    substr($self,-length($ext))="";
  };
  $self=join("",$self,$ext);
  return $self if $self eq $orig;
  my($newn)=$orig->move($self);
  eex($orig,$self,$newn);
  $newn;
};
sub fn_date {
  for(shift) {
    s{^date:\s*}{}i;
    return serdate(str2time($_));
  };
};
1;
