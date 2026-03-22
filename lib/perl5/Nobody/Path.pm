package Nobody::Path;
use Nobody::Util::Import;
require Exporter;
our(@ISA) = qw(Exporter);
package Nobody::Util;
use Path::Tiny;
use Mojo::Path;
push(@Path::Tiny::ISA,__PACKAGE__);
push(@Mojo::Path::ISA,__PACKAGE__);


use File::stat ();
sub mtime($) {
  shift->stat;
  $st_mtime;
};
sub inode($) {
  return [shift->stat]->[1];
};
my($cwd);
sub cwd {
  return $cwd if defined $cwd;
  ($cwd=path("."))->absolute;
};
1;
