package RB::Wiki::Entry;

use Manager::Dialog qw(ApproveCommands);
use PerlLib::SwissArmyKnife;
use RB::Wiki::Profile;
use Termios::Text;

use Data::Dumper;
use IO::File;
use Text::Wrap;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Title FN _FQFN _Text MyServer Links KeyConcepts MyProfile Categories Overview Generated /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyServer($args{Server});
  my $filename;
  if ($args{Title}) {
    $self->Title($args{Title});
    $filename = $self->Title;
    if ($filename =~ /\s/) {
      $filename =~ s/\s/_/g;
    }
    # $filename =~ s/\(/%28/g;
    # $filename =~ s/\)/%29/g;
    $filename .= ".wiki";
  }
  $self->FN($args{Filename} || $filename);
  $self->Categories($ARGVS{Categories} || {});
  $self->Links($args{Links} || {});
  $self->Generated({});
}

sub FQFN {
  my ($self,%args) = @_;
  if (! $self->_FQFN) {
    my $tmp = $self->FN;
    $tmp =~ s/^(https?|file):\/+//sg;
    $self->_FQFN($self->MyServer->DataDir."/".$tmp);
  }
  return $self->_FQFN;
}

sub Text {
  my ($self,%args) = @_;
  if (! $self->_Text) {
    my $fqfn = $self->FQFN;
    my $contents;
    if (-f $fqfn) {
      $contents = `cat "$fqfn"`;
    }
    my $text = Termios::Text->new
      (Contents => $contents);
    $self->_Text($text);
  }
  return $self->_Text;
}

sub SaveText {
  my ($self,%args) = @_;
  print "Saving Text: ".$self->FQFN."\n";
  system 'mkdir -p '.shell_quote(dirname($self->FQFN));
  my $fh = IO::File->new;
  $fh->open("> ".$self->FQFN);
  print $fh $self->Text->Contents;
  $fh->close;
}

sub Checkout {
  my ($self,%args) = @_;
  chdir $self->MyServer->DataDir;
  my $c = [
	   "mvs update \"".$self->FN."\"",
	  ];
  ApproveCommands
    (
     Commands => $c,
     Method => "parallel",
    );
  # store a hash so that we can determine whether the file has been editted

  my $profile = $self->Text->Profile;
  $self->MyProfile($profile);
}

sub Update {
  my ($self,%args) = @_;

  # maybe do some sanity checks on this, like make sure its been checked out recently, etc

  # check the hash
  # if its different, etc.
  my $profile = $self->Profile;

  $self->Proofread;
  # ensure it's written
  $self->SaveText;

  my $c = [
	   "chdir ".$self->MyServer->DataDir,
	   "mvs update \"".$self->FN."\"",
	   ];

  ApproveCommands
    (
     Commands => $c,
     Method => "parallel",
    );
}

sub Commit {
  my ($self,%args) = @_;
  if ($args{SkipIfFileExists} and -f $self->FQFN) {
    print "Skipping\n";
    return;
  }

  # maybe do some sanity checks on this, like make sure its been checked out recently, etc

  # check the hash
  # if its different, etc.
  my $profile = $self->Profile;

  $self->Proofread;
  # ensure it's written
  $self->SaveText;

  if (! $args{Skip}) {
    my $datadir = $self->MyServer->DataDir;
    my $file = `chase $datadir`;
    chomp $file;
    my $c = [
	     "cd $file && mvs commit -m 'Auto upload 2' ".shell_quote($self->FQFN),
	    ];

    ApproveCommands
      (
       Commands => $c,
       Method => "parallel",
       AutoApprove => $args{AutoApprove},
      );
  }
}

sub Profile {
  my ($self,%args) = @_;
  $self->Text->Profile;
}

sub Axiomatize {
  my ($self,%args) = @_;
  # use text to knowledge formation tools to generate knowledge from
  # this text
  $self->Text->Axiomitize;
}

sub DraftStatus {
  my ($self,%args) = @_;
  # the quality of the text to be formalized, whether it is ready or
  # not
  # $self->Text->DraftStatus;
}

sub Proofread {
  my ($self,%args) = @_;
  # apply terminology management
  $self->Text->Proofread;
}

sub Generate {
  my ($self,%args) = @_;
  my @contents;

  $self->AddToGenerated(0,"== Overview ==");
  if (defined $self->Overview) {
    # this is where you would put the overview, if you had one
    $self->AddToGenerated(0,$self->Overview);
  } else {
    $self->AddToGenerated(0,"Nothing is known about ".$self->Title." at this time.  Please feel free to add knowledge here.");
  }

  $self->AddToGenerated(50,"== External Links ==");
  if (scalar %{$self->Links}) {
    # sort by date
    # put the wikipedia page here if it has one
    foreach my $link (sort keys %{$self->Links}) {
      $self->AddToGenerated(50,"[$link ".$self->Links->{$link}."]");
    }
  } else {
    $self->AddToGenerated(50,"No known external links.");
  }

  foreach my $cat (sort keys %{$self->Categories}) {
    $self->AddToGenerated(70, "[[Category:$cat]]");
  }

  $self->AddToGenerated(100,"Automatically generated from URIs by [http://frdcsa.onshore.net/frdcsa/internal/reasonbase/index.html ReasonBase]");
}

sub AddToGenerated {
  my ($self,$order,@text) = @_;
  if (! exists $self->Generated->{$order}) {
    $self->Generated->{$order} = [];
  }
  push @{$self->Generated->{$order}}, @text;
}

sub Compose {
  my ($self,%args) = @_;
  # we are going to get a set of keys with sort order and text
  $self->Generate;

  my @list;
  foreach my $key (sort {$a <=> $b} keys %{$self->Generated}) {
    push @list, @{$self->Generated->{$key}};
  }
  my $contents = join("\n\n",@list);

  $self->_Text
    (Termios::Text->new
     (Contents => $contents));
  return $contents;
}

sub PrettyPrint {
  my ($self,%args) = @_;
  my $initial_tab = "";		# Tab before first line
  my $subsequent_tab = "";	# All other lines flush left
  my $title = $self->Title;
  $title =~ s/\n\n+/\n\n/g;
  print $title."\n\n";
  my $t = $self->Text->Contents;
  if ($t) {
    # $t =~ s/\[\[//g;
    # $t =~ s/\]\]//g;
    print wrap($initial_tab, $subsequent_tab, ($t))."\n";
  }
}

1;
