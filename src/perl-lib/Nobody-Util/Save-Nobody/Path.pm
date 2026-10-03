package Nobody::Path;
use Path::Tiny;
our(@ISA)=qw(Path::Tiny);
our(@EXPORT,%EXPORT);
BEGIN {
  $EXPORT{$_}++ for qw( getcwd );
  $EXPORT{$_}++ for (@Path::Tiny::EXPORT_OK, @PATH::Tiny::EXPORT);
  @EXPORT=keys %EXPORT;
};
sub getcwd {
  path(readlink("/proc/self/cwd"));  
};
1;
