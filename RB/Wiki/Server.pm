package RB::Wiki::Server;

use Data::Dumper;
use Manager::Dialog qw(ApproveCommands Message);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [

		    qw / MyClient Host Username Password DataDir Wiki
		    Project /

		   ];

sub init {
  my ($self,%args) = @_;
  $self->MyClient($args{Client});
  $self->Host($args{Host});
  $self->Username($args{Username});
  $self->Password($args{Password});
  $self->Project($args{Project});
  my $systemdir = $UNIVERSAL::systemdir || "/var/lib/myfrdcsa/codebases/internal/reasonbase";
  $self->DataDir($systemdir."/data/servers/".$self->Host."/".$self->Project);
  mkdir $self->DataDir unless -d $self->DataDir;
  $self->Wiki($args{Wiki});
}

sub Login {
  my ($self,%args) = @_;
  if ($self->Host and $self->Username and $self->Password and $self->DataDir and $self->Wiki) {
    chdir $self->DataDir;
    my $commands =
      [
       "mvs login -d ".
       $self->Host.
       " -u ".
       $self->Username.
       " -p ".
       $self->Password.
       " -w '".$self->Wiki."/index.php'",
      ];
    ApproveCommands
      (Commands => $commands,
       Method => "parallel");
  } else {
    Message
      (Message => "Not enough information to login yet.");
  }
}

sub ScanDataDir {
  my ($self,%args) = @_;
  my $dd = $self->DataDir;
  foreach my $file (split /\n/, `ls $dd`) {
    #
  }
}

sub CleanDataDir {
  my ($self,%args) = @_;
  # remove all the local copies of entries in the datadir for this
  # server
  # do santify checks
}

1;
