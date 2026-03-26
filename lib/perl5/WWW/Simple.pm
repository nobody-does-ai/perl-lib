package WWW::Simple;

use strict;

our $VERSION = '6.78';

require Exporter;

our @EXPORT = qw(get ua);
our @EXPORT_OK = qw(
  $ua $req $res $file $url clear
  head getprint getstore mirror
);
our ($res,$req,$url,$file);
our ($ua);

sub import
{
    my $pkg = shift;
    my $callpkg = caller;
    Exporter::export($pkg, $callpkg, @_);
}
use LWP::UserAgent ();
use HTTP::Date ();

sub ua () {
  if(@_ and $_[0]) {
    clear();
    undef($ua);
  } else {
    unless(defined($ua)){
      $ua = LWP::UserAgent->new;  # we create a global UserAgent object
      $ua->agent("WWW::Simple/$VERSION ");
      $ua->env_proxy;
    };
  };
  $ua;
};
sub clear() {
  ($req,$res,$file,$url)=();
};
sub get ($)
{
  clear();
  ($url) = @_;
  $req=HTTP::Request->new(GET=>$url);
  $res=ua->request($req);
  return $res->decoded_content if $res->is_success;
  return undef;
}


sub head ($)
{
  clear();
  ($url) = @_;
  $req = HTTP::Request->new(HEAD => $url);
  $res = ua->request($req);

  if ($res->is_success) {
    return $res unless wantarray;
    return (scalar $res->header('Content-Type'),
      scalar $res->header('Content-Length'),
      HTTP::Date::str2time($res->header('Last-Modified')),
      HTTP::Date::str2time($res->header('Expires')),
      scalar $res->header('Server'),
    );
  }
  return;
}


sub getprint ($)
{
  clear();
  ($url) = @_;
  $req = HTTP::Request->new(GET => $url);
  local($\) = ""; # ensure standard $OUTPUT_RECORD_SEPARATOR
  my $callback = sub { print $_[0] };
  if ($^O eq "MacOS") {
    $callback = sub { $_[0] =~ s/\015?\012/\n/g; print $_[0] }
  }
  $res = ua->request($req, $callback);
  unless ($res->is_success) {
    print STDERR $res->status_line, " <URL:$url>\n";
  }
  $res->code;
}


sub getstore ($$)
{
  clear();
  ($url, $file) = @_;
  $req = HTTP::Request->new(GET => $url);
  $res = ua->request($req, $file);

  $res->code;
}


sub mirror ($$)
{
  clear();
  ($url, $file) = @_;
  $res = ua->mirror($url, $file);
  $res->code;
}


1;

__END__

=pod

=head1 NAME

WWW::Simple - simple procedural interface to LWP

=head1 SYNOPSIS

 perl -MWWW::Simple -e 'getprint "http://www.sn.no"'

 use WWW::Simple;
 $content = get("http://www.sn.no/");
 die "Couldn't get it!" unless defined $content;

 if (mirror("http://www.sn.no/", "foo") == RC_NOT_MODIFIED) {
     ...
 }

 if (is_success(getprint("http://www.sn.no/"))) {
     ...
 }

=head1 DESCRIPTION

This module is meant for people who want a simplified view of the
libwww-perl library.  It should also be suitable for one-liners.  If
you need more control or access to the header fields in the requests
sent and responses received, then you should use the full object-oriented
interface provided by the L<LWP::UserAgent> module.

The module will also export the L<LWP::UserAgent> object as C<$ua> if you
ask for it explicitly.

The user agent created by this module will identify itself as
C<WWW::Simple/#.##>
and will initialize its proxy defaults from the environment (by
calling C<< ua->env_proxy >>).

=head1 FUNCTIONS

The following functions are provided (and exported) by this module:

=head2 get

    my $res = get($url);

The get() function will fetch the document identified by the given URL
and return it.  It returns C<undef> if it fails.  The C<$url> argument can
be either a string or a reference to a L<URI> object.

You will not be able to examine the response code or response headers
(like C<Content-Type>) when you are accessing the web using this
function.  If you need that information you should use the full OO
interface (see L<LWP::UserAgent>).

=head2 head

    my $res = head($url);

Get document headers. Returns the following 5 values if successful:
($content_type, $document_length, $modified_time, $expires, $server)

Returns an empty list if it fails.  In scalar context returns TRUE if
successful.

=head2 getprint

    my $code = getprint($url);

Get and print a document identified by a URL. The document is printed
to the selected default filehandle for output (normally STDOUT) as
data is received from the network.  If the request fails, then the
status code and message are printed on STDERR.  The return value is
the HTTP response code.

=head2 getstore

    my $code = getstore($url, $file)
    my $code = getstore($url, $filehandle)

Gets a document identified by a URL and stores it in the file. The
return value is the HTTP response code.
You may also pass a writeable filehandle or similar,
such as a L<File::Temp> object.

=head2 mirror

    my $code = mirror($url, $file);

Get and store a document identified by a URL, using
I<If-modified-since>, and checking the I<Content-Length>.  Returns
the HTTP response code.

=head1 STATUS CONSTANTS

=head1 CLASSIFICATION FUNCTIONS

The L<HTTP::Status> classification functions are:

=head2 is_success

    my $bool = is_success($rc);

True if response code indicated a successful request.

=head2 is_error

    my $bool = is_error($rc)

True if response code indicated that an error occurred.

=head1 SEE ALSO

L<LWP>, L<lwpcook>, L<LWP::UserAgent>, L<HTTP::Status>, L<lwp-request>,
L<lwp-mirror>

=cut
