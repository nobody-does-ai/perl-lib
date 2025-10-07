package QMI::Util;
use common::sense;
use Nobody::Util;
our(@ISA,@subs)=qw( Exporter );
our(@subs);
our(@EXPORT)=qw(
qmi_settings qmi_iface
qmi_status qmi_settings() qui_iface() cidr($)  qmi_parse(@) 
qmi_network(@) qmi_stop() qmi_start() qmi_bounce()  qmi_capture
apply_settings(\%) apply_cmds qmi_run(@)
);
use Exporter;

use Symbol;
use IPC::Open3;
use IO::Select;

sub qmi_status {
  local(@_)=map { split m{[\s']}} qmi_capture(qw(
    /opt/sbin/qmicli --wds-get-packet-service-status
  ));
  @_=grep { m{connected} } @_;
  return wantarray ? @_ : shift;
};
sub qmi_run(@) {
  local (@_)=qx(@_);
  join("",@_);
};
sub qmi_iface() {
  local(@_)=qx( /opt/sbin/qmicli -w);
  shift;
};
sub qmi_parse(@) {
  path("/run/state.qmi")->spew(pp(\@_));
  chomp(@_);
  $_=join(" ",split) for @_;
  @_ = grep { !m{Family|Domains|]} } @_;
  for (@_) {
    y/A-Z/a-z/;
    s{ipv4 }{};
    s{ .*:}{:};
    s{: *}{ };
    s{subnet}{netmask};
  };
  my (%data)= map { split } @_;
  ($data{cidr},$data{network})=cidr_and_net($data{netmask},$data{address});
  $data{iface}=join("",map { split } qmi_iface());
  $data{addr}=join("/",$data{address},$data{cidr});
  $data{metric}=int(1000+rand(1000));
  my @bad=grep { !defined($data{$_}) } qw( address cidr iface mtu gateway );
  if(@bad) {
    die "missing info: @bad\n";
  };    
  return \%data;
};
sub cidr_and_net($$) {
  local(@_)=@_;
  my($mask,$addr)=map { "$_" } splice(@_);
  my($val)=0;
  my($hex);
  $"=$,=" ";
  my ($cidr,$MASK);
  for($mask){
    $_=sprintf("%02x%02x%02x%02x",split(m{[.]}));
    $MASK=hex($_);
    die "bad netmask: $_" unless (@_=m{^(f*)([ec8]?)(0*)$}) and length==8;
    $_=4*length for $_[0];
    $_[1]=~y/8ce/123/;
    $cidr=$_[0]+$_[1];
  };
  for(grep { defined } $addr){
    $_=sprintf("%02x%02x%02x%02x",split(m{[.]}));
    $_=sprintf("%08x",hex($_)&$MASK);
    @_=(map { hex } grep { length } split m{(..)});
    return ( $cidr, join(".",@_));
  };
  return $cidr;
};
sub cidr($) {
  local(@_)=cidr_and_net($_[0],"255.255.255.255");
  shift;
};
sub qmi_settings() {
  $?=0;
  local(@_)=qx(
    /opt/sbin/qmicli --wds-get-current-settings 2>&1
  );
  die "qmicli returned $?" if $?;
  return qmi_parse(@_);
}
unless(caller) {
  open(STDOUT,">&STDERR");
  say "testing module, since you ran it";
  say pp( qmi_settings );
};

1;
