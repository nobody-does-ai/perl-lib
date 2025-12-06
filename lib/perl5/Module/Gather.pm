
END {
  $,=" ";
  my(@out);
  local(%INC)=%INC;
  for(keys %INC) {
    next if substr($_,0,1) eq '/';
    for($INC{$_}){
      s{^$ENV{PWD}/+}{};
    };
    push(@out,[$_, $INC{$_}]) if $_ ne $INC{$_};
  };
  my($cwd)=path($ENV{PWD});
  my($lib)=$cwd->child("lib");
  for(@out) {
    my($dst,$src)=@$_;
    next if $dst eq $src;
    next if -e $dst;
    $dst=$lib->child($dst)->touchpath;
    path($src)->copy($dst);
  }; 
};
1;
