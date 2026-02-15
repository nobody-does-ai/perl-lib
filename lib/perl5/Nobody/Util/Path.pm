package Nobody::Util::Path;
use Nobody::Util::Import;
require Exporter;
our(@ISA) = qw(Exporter);
package Nobody::Util;
use Path::Tiny;

package Path::Tiny;
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
