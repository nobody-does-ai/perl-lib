#!/usr/bin/perl
# vim: ts=2 sw=2 ft=perl
package Nobody::Path;
use Exporter qw(import export_to_level);
use Carp::Always;
our(@EXPORT,%PACK);
#        push(@{$PKG{$_}}, get_exports($_));
qw( path tempdir tempfile );;
BEGIN { push(@EXPORT, @Path::Tiny::EXPORT, @Path::Tiny::EXPORT_OK) };
use subs qw( eex qquote );
BEGIN {
  *eex=\&Nobody::PP::eex;
  *qquote=\&Data::Dumper::qquote;
  push(@EXPORT, @Path::Tiny::EXPORT_OK, @Path::Tiny::EXPORT);
};
sub uri {
  push(@EXPORT,load_pkg(qw(URI)));
  die "$@" if "$@";
  return URI->new($_[0]);
}
sub mime {
  my($in)=shift;
  return magic->checktype_filename(shift);
}
sub magic {
  my($self)=shift;
  require File::MMagic;
  my($magic)=File::MMagic->new;
  $magic;
};
1;
