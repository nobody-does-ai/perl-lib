package Make::Task;
# vim: ts=2 sw=2 ft=perl
use common::sense;
use feature 'lexical_subs';
use Nobody::Util;
use Nobody::PP;
use Scalar::Util qw(blessed reftype);
use Hash::Util   qw(lock_keys);
use List::Util   qw(min max);

our $VERSION = "0.01.0";

our @inst = (undef);  # index 0 unused; handles are always true
our %idx;    # $path => { tgt => [inst indices], src => [inst indices] }

my sub mtime { (stat "$_[0]")[9] // 0 }

my sub run_jobs {
  my ($max, @subs) = @_;
  return unless @subs;
  my (@pids, @failed);
  for my $sub (@subs) {
    if (@pids >= $max) {
      my $pid = waitpid(-1, 0);
      push @failed, $pid if $?;
      @pids = grep { $_ != $pid } @pids;
    }
    my $pid = fork // die "fork: $!";
    if ($pid == 0) { $sub->(); exit 0 }
    push @pids, $pid;
  }
  for my $pid (@pids) {
    waitpid($pid, 0);
    push @failed, $pid if $?;
  }
  die scalar(@failed) . " Make::Task job(s) failed\n" if @failed;
}

sub new {
  my ($class, %args) = @_;
  my $i = scalar @inst;
  my %data = (
    src    => $args{src}   // [],
    tgt    => $args{tgt},
    needs  => $args{needs},
    build  => $args{build},
    jobs   => $args{jobs}  // 4,
    _idx      => $i,
    _done     => 0,
    _paths    => [],
    _depfile  => undef,
  );
  push @inst, bless \%data, $class;
  lock_keys(%{$inst[-1]});
  my $handle = bless \$i, $class;

  my @tgt = grep { !ref } (ref $args{tgt} eq 'ARRAY' ? @{$args{tgt}}
                          : defined $args{tgt} && ref $args{tgt} ne 'CODE' ? ($args{tgt})
                          : ());
  my @src = grep { !ref } @{$args{src} // []};
  push @{$idx{$_}{tgt}}, $i for @tgt;
  push @{$idx{$_}{src}}, $i for @src;

  $handle;
}

sub self {
  my ($self) = @_;
  return $inst[$$self] if reftype($self) eq 'SCALAR';
  return $self;
}

sub idx   { shift->self->{_idx} }
sub src   { @{shift->self->{src}} }
sub tgt   { my $t = shift->self->{tgt}; ref $t eq 'ARRAY' ? @$t : defined $t ? ($t) : () }
sub build { shift->self->{build} }

sub instances { @inst }

my sub resolve_src {
  map { (blessed($_) && $_->isa('Make::Task')) ? $_->paths : "$_" } @_;
}

sub paths {
  my ($self) = shift->self;
  $self->run unless $self->{_done};
  @{$self->{_paths}};
}

sub run {
  my ($self) = shift->self;
  return $self if $self->{_done};
  $self->{_done} = 1;

  my @srcs  = resolve_src(@{$self->{src}});
  my $tgt   = $self->{tgt};
  my $build = $self->{build};
  my $jobs  = $self->{jobs};

  if (!ref $tgt || ref $tgt eq 'ARRAY') {
    # Concrete: fixed output(s), all srcs feed one build
    my @outs  = ref $tgt eq 'ARRAY' ? @$tgt : defined $tgt ? ($tgt) : ();
    my $old_t = min(map { -e "$_" ? mtime($_) : 0 } @outs);
    my $stale = !$old_t || (max(0, map { mtime($_) } @srcs) > $old_t);
    if ($stale && $build) {
      $build->(@srcs, @outs);
      my @missing = grep { !-e $_ } @outs;
      die "Make::Task: targets missing after build: @missing\n" if @missing;
    }
    $self->{_paths} = \@outs;
  } else {
    # Abstract: tgt is CODE, derive outputs per src
    my (@all_outs, @work);
    for my $src (@srcs) {
      my @outs    = map { "$_" } $tgt->($src);
      my $src_t   = mtime($src);
      my $stale   = grep { !-e "$_" || $src_t > mtime($_) } @outs;
      push @all_outs, @outs;
      push @work, sub { $build->($src, @outs) } if $stale && $build;
    }
    run_jobs($jobs, @work);
    $self->{_paths} = \@all_outs;
  }
  $self;
}

sub clean {
  my ($self) = shift->self;
  unlink $_ for grep { !ref && -e } $self->tgt;
  $self->{_done}  = 0;
  $self->{_paths} = [];
  $self;
}

sub dirty {
  my ($self) = shift->self;
  $self->{_done}  = 0;
  $self->{_paths} = [];
  $self;
}

sub prune {
  my ($class) = @_;
  for my $task (grep { defined } @inst[1..$#inst]) {
    my @missing = grep { !-e $_ && !$idx{$_}{tgt} }
                  grep { !ref }
                  @{$task->{src}};
    next unless @missing;

    if (defined $task->{build}) {
      $task->clean;
    } else {
      # dep-only task (from a .d file): missing src means stale deps
      unlink $task->{_depfile} if defined $task->{_depfile} && -e $task->{_depfile};
      for my $tgt (grep { !ref } $task->tgt) {
        unlink $tgt if -e $tgt;
        $inst[$_]->dirty for @{$idx{$tgt}{tgt} // []};
      }
    }
  }
}

# Parse .d files: attach deps to known tasks, or create dep-only tasks.
sub include {
  my ($class, @globs) = @_;
  for my $file (map { glob } @globs) {
    (my $text = path($file)->slurp) =~ s/\\\n//g;
    for my $line (split /\n/, $text) {
      next if $line =~ /^\s*(?:#.*)?$/;
      next unless $line =~ /^(\S+):\s*(.*)/;
      my ($target, @deps) = ($1, grep { $_ ne $1 } split ' ', $2);
      if (my $existing = $idx{$target}{tgt}) {
        for my $ti (@$existing) {
          push @{$inst[$ti]{src}}, @deps;
          push @{$idx{$_}{src}}, $ti for @deps;
        }
      } else {
        my $t = $class->new(tgt => $target, src => \@deps);
        $t->self->{_depfile} = $file;
      }
    }
  }
}

1;
