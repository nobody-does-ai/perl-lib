package Module::Gather;

use 5.008003;
use common::sense;
use File::stat qw( :FIELDS );
use Nobody::Util qw(!any);
use vars qw( $dst $dry );
BEGIN {
  $dry=$ENV{MODULE_GATHER_DRY}//1;
  if($dry) {
    STDERR->say("set MODULE_GATHER_DRY to 0 to copy");
  };
  for($ENV{MODULE_GATHER_DIR}){
    if(defined) {
      $dst=$ENV{MODULE_GATHER_DIR};
    } else {
      $dst="gather";
    }
    $dst=path($dst)->realpath->mkdir;
  };
}
END {
  for my $key(keys %INC) {
    for( $INC{$key} ) {
      my($tmp)=$dst->child($key);
      my($src)=path($_)->realpath;
      next if($tmp eq $src);
      next if($dst->subsumes($src));
      my($full_dst)=$dst->child($key);
      say STDERR $src, "\n   ", $full_dst;
      unless($dry) {
        $full_dst->touchpath;
        $tmp->remove;
        $src->copy($full_dst);
      };
    };
  };
};
1;
=head1 NAME

Module::Gather - The great new Module::Gather!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Module::Gather;

    my $foo = Module::Gather->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Rich Paul <cpaul@cpan.org>

=head1 BUGS

Please report any bugs or feature requests to C<bug-module-gather at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Module-Gather>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Module::Gather


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Module-Gather>

=item * Search CPAN

L<https://metacpan.org/release/Module-Gather>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2026 by Rich Paul <cpaul@cpan.org>.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1; # End of Module::Gather
