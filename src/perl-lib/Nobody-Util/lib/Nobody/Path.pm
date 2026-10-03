#!/usr/bin/perl
# vim: ts=2 sw=2 ft=perl
package Nobody::Path;
use Exporter;
use Carp::Always;
our(@EXPORT,@EXPORT_OK);
BEGIN { *EXPORT=\@EXPORT_OK };
sub import {
  goto \&Exporter::import
}
use Path::Tiny qw( path tempdir tempfile );;
sub eex {
	goto \&Nobody::PP::eex;
};
BEGIN {
  push(@EXPORT, @Path::Tiny::EXPORT_OK, @Path::Tiny::EXPORT);
};
sub Path::Tiny::selfpp($) {
  my($rval)=shift;
  return "path(".qquote($rval).")";
}
sub URI::selfpp($) {
  my($rval)=shift;
  return "uri(".qquote($rval).")";
};
1;
