use Test::More tests => 4, import => ['!fail'];
use lib "lib";
use LWP::Simple;
use URI;
use URI::virtual;
use Path::Tiny;
use strict;

my $tstdir = "file://$ENV{PWD}/tmp";
my $relurl = "01-loaduri.cfg";
my $tstcfg = "loaduri $tstdir";

my($cfg)=path("tmp")->mkdir->child("$relurl")->spew("$tstcfg");
URI::virtual::lists($cfg);
my ( $uri, $res );
ok($uri=URI->new("virtual://loaduri/01-loaduri.cfg"));
ok(ref $uri eq "URI::virtual");
ok($res = $uri->resolve()->canonical());
ok(substr($res,0,length($tstdir)) eq $tstdir);
1;
