use File::stat qw( :FIELDS );
use Nobody::Util qw(!any);

END {
  my($dst)=path("gather")->mkdir;
  for my $key(keys %INC) {
    for( $INC{$key} ) {
      my($tmp)=$dst->child($key)->touchpath;
      $tmp->remove;
      my($src)=path($_)->realpath;
      next if($tmp eq $src);
      next if($dst->subsumes($src));
      $src->copy($dst->child($key)->touchpath); 
    };
  };
};
1;
