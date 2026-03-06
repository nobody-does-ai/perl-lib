package Tiny::Path;

use base qw( Path::Tiny );

sub path {
  require Path::Tiny;
  *path=\&Path::Tiny;
  goto \&path;
};

1;
