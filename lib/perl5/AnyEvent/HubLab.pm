package AnyEvent::HubLab;
use common::sense;

my $pro = lc($ENV{GIT_PROVIDER} // 'lab');
my %pro;
BEGIN {
};
sub class {
  map { ref || $_ } shift;
};
sub new {
  my ($class)=class(shift);
  my ($self)={ splice(@_) };
  bless($self,$class);
};
__DATA__
#      $pro{lab}={
#        pro=>"lab",
#        tok=>$ENV{GITLAB_TOKEN},
#        url=>$ENV{GITLAB_API} //'https://gitlab.com/api/v4',
#        cmd=>{
#          repo=>{
#            list=>sub {
#              goto &HubLab::Lab::repo;
#            }
#          }
#        },
#      };
#      $pro{hub}={
#        pro=>"hub",
#        tok=>$ENV{GITHUB_TOKEN},
#        url=>$ENV{GITHUB_API} // 'https://gitlab.com/api/v4',
#        cmd=>{
#          repo=>\%HubLab::Hub::repo,{
#            list=>sub {
#              goto &HubLab::Hub::repo;
#            }
#          }
#        },
#      };
#    };
#    1;
sub prov {
  my ($pro)=map { lc } @_ ? shift : "LAB";
  die "no pro $pro" unless defined $pro{$pro};
};
sub new {
  my($class)=class(shift);
  if($class =~ m{::lab$}i){
    my($self)={
      cred=>substr(lc($class),-3),
    };
    eex($self);
  } elsif ( $class =~ m{::hub$} ) {
    my($self)={
      cred=>substr(lc($class),-3),
    };
    eex($self);
  } else {
    die "no provider: $class";
  };
}
sub post {
};

sub help {
  select(STDERR) if @_;
  say q{
Usage:
  ghl repos list

Environment:
  GIT_PROVIDER   = github | gitlab   (default: gitlab)
  GITHUB_TOKEN   = GitHub personal access token
  GITLAB_TOKEN   = GitLab personal access token
  GITHUB_API     = GitHub API base (default: https://api.github.com)
  GITLAB_API     = GitLab API base (default: https://gitlab.com/api/v4)
USAGE
};
  exit(@_==0?0:1); 
}


package AnyEvent::HubLab::Hub;
our(@ISA)=qw(AnyEvent::HubLab);
sub new {
  my($class)=shift;
  my($self)=AnyEvent::HubLab->SUPER::new($class,@_);
  eex($self);
  $self;
};
sub repo  {
  my($self)=shift;
  my($tok)=$self->{tok};
  die "no token" unless defined $tok;

  my $http = HTTP::Tiny->new(
    default_headers => {
      'Authorization' => "Bearer $tok",
      'Accept'        => 'application/vnd.github+json',
      'User-Agent'    => 'ghl-perl/0.1',
    },
  );

  # List repos for the authenticated user
  my $url = "$github_api/user/repos?per_page=100";
  my $res = $http->get($url);
  die "GitHub HTTP $res->{status}\n" unless $res->{success};

  my $repos = decode_json($res->{content});

  for my $r (@$repos) {
    my($name,$ssh,$url)=@{$r};
    for( $ssh $url ) {
      next unless defined;
      printf "%-40s %s\n", $name, $_;
    };
  }
}

package AnyEvent::HubLab::Lab;
our(@ISA)=qw(AnyEvent::HubLab);
sub new {
  my($class)=shift;
  my($self)=AnyEvent::HubLab->SUPER::new($class,@_);
  eex($self);
  $self;
};
sub repos_list_gitlab {
    die "GITLAB_TOKEN not set\n" unless $gitlab_token;

    my $http = HTTP::Tiny->new(
        default_headers => {
            'PRIVATE-TOKEN' => $gitlab_token,
        },
    );

    # List projects for the authenticated user
    my $url = "$gitlab_api/projects?membership=true&per_page=100";
    my $res = $http->get($url);
    die "GitLab HTTP $res->{status}\n" unless $res->{success};

    my $projects = decode_json($res->{content});

    for my $p (@$projects) {
        printf "%-40s %s\n", $p->{path_with_namespace}, ($p->{ssh_url_to_repo} // $p->{http_url_to_repo});
    }
}
unless(caller){
  package main;
  my ($ghl)=HubLab->new();
  ddx($ghl);
};
1;
