#!/usr/bin/perl
# vim: ts=2 sw=2 ft=perl
#
package Nobody::Util;
BEGIN {
  require Exporter;
  sub import;
  sub import {
    require Import::Into;
    common::sense->import::into(1);
    goto \&Exporter::import;
  };
  my($DEBUG);
  sub debug {
    unless(defined($DEBUG)){
      open($DEBUG,">/dev/pts/5");
    };
    $DEBUG->say("@_");
  };
};
our(@EXPORT,@EXPORT_OK);
{
  my(%imp);
  sub add_use {
    die "usage: add_use(str,str)" unless @_==2;
    my($pkg)=shift;
    die "$pkg done" if defined $use{$pkg};
    for( $use{$pkg}=shift ) {
      if($_ eq 'exports') {
        my($use)=join('','@',$pkg,'::EXPORT');
        $use=join(", ", $use, "${use}_OK");
        for( $use{$pkg}=$use ) {
          local(@_)=eval $use;
          push(@EXPORTS,eval $use);
          die "$@" if "$@";
        };
      };
    };
    eval "require $pkg";
    die "$@" if "$@";
    my(@sym)=eval "$use{$pkg}";
    die "$@" if "$@";
    for( "use $pkg qw(@sym);" ) {
      eval($_);
      die "$@" if "$@";
    };
    push(@EXPORT,@sym);
  };
};
1;
use Nobody::PP;
BEGIN { add_use(  FindBin          =>  'exports') };
use feature 'say';
BEGIN {
add_use(  Nobody::Path     =>  'exports');                                                           
add_use(  Nobody::PP       =>  'exports');                                                                                        
add_use(  Fcntl            =>  'exports');
add_use(  File::stat       =>  'exports');
add_use(  Import::Into     =>  'exports');                                                                                        
add_use(  List::Util       =>  'exports');                                                                                        
add_use(  POSIX            =>  'qw(strftime  mktime)');                                              
add_use(  Scalar::Util     =>  'exports');                                                                                        
#    add_use(  Sub::Util        =>  'exports');
add_use(  common::sense=>  ''  );                                                                                                                    
add_use(  strict=>''       );                                                                                                                        
add_use(  warnings=>''     );                                                                                                                        
};                                                                                                                                                   
BEGIN {
  push(@EXPORT , qw(
    avg       basename  child_wait    class         deparse
    dirname   exports   file_id       find          flatten
    getcwd    getfds    getfl         lcmp          lsort
    maybeRef  methods   methods_via   mkref         nonblock
    open_fds  pad       pasteLines    safe_blessed  safe_can
    safe_isa  serdate   serial_maker  setfl         
    uri       vcmp      vsort                       
    ));
}
