package Eolas;

use BOSS::Config;
use Capability::FactExtraction;
use Capability::TextAnalysis;
use Eolas::Annotator;
use MyFRDCSA qw(ConcatDir Dir);
use PerlLib::ToText;
use RB::Wiki::Client;
use RB::Wiki::Entry;
use RB::Wiki::Entry::Page;
use RB::Wiki::Entry::Entity;
use RB::Wiki::Entry::EntityType;
use RB::Wiki::Entry::Entity::ContainingPage;
use Sayer;

use Cache::FileCache;
use Data::Dumper;
use IO::File;
use WWW::Mechanize::Cached;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Project URIsFunction Config CacheObj Cacher MySayer MyTextAnalysis MyToText
   MyWikiClient TAResults MyAnnotator ProjectConfig WikiConfig /

  ];

sub init {
  my ($self,%args) = @_;
  $specification = q(
	-p <project>	Project name
	-s		Skip commits
	--siee		Skip commits if entry exists
	-a		Commit without individual approval
	-q		Quit after preprocessing texts
  );

  $self->Config
    (BOSS::Config->new
     (
      Spec => $specification,
      ConfFile => "/etc/myfrdcsa/config/reasonbase.conf",
     ));
  my $conf = $self->Config->CLIConfig;
  my $projectinfo = $self->Config->RCConfig->{Project};

  my $project = $conf->{'-p'};
  $self->Project($project);
  die "Project not in conf file\n" unless exists $projectinfo->{$project};

  $self->ProjectConfig($projectinfo->{$project});
  $self->WikiConfig($self->ProjectConfig->{Wiki});

  $self->WikiConfig->{BaseURI} = "http://".$self->WikiConfig->{Host}."/".$self->WikiConfig->{Wiki}."/index.php";
  $self->WikiConfig->{Project} = $project;

  $UNIVERSAL::baseuri = $self->Config->RCConfig->{BaseURI};
  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"reasonbase");
  $self->CacheObj
    (Cache::FileCache->new
     ($projectinfo->{$project}));

  $self->Cacher
    (WWW::Mechanize::Cached->new
     (
      cache => $self->CacheObj,
      timeout => 15,
     ));

  $self->MyTextAnalysis
    (Capability::TextAnalysis->new
     (
      Sayer => $self->MySayer,
      DontSkip => {
		   "Tokenization" => 1,
		   "TermExtraction" => 1,
		   "DateExtraction" => 1,
		   "NounPhraseExtraction" => 1,
		   "SemanticAnnotation" => 1,
		  },
     ));

  $self->MyToText
    (PerlLib::ToText->new);

  $self->MyWikiClient
    (RB::Wiki::Client->new
     (
      %{$self->WikiConfig},
     ));

  $self->TAResults({});
  $self->URIsFunction($args{URIsFunction});
}

sub Execute {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;

  foreach my $uri (@{$self->URIsFunction->($self)}) {
    print Dumper($uri);
    $self->ProcessURI
      (
       URI => $uri,
      );
  }

  print Dumper([sort $self->MyWikiClient->Entries->Keys]);

  print "Saving results for later loading\n";
  my $fh = IO::File->new();
  my $datafile = $UNIVERSAL::systemdir."/data/servers/".$self->MyWikiClient->MyServer->Host."/".$self->WikiConfig->{Project}.".dat";
  print Dumper({DataFile => $datafile});
  $fh->open(">".$datafile)
    or "die cannot open data file.\n";
  print $fh Dumper($self->TAResults);
  $fh->close();

  if (exists $conf->{'-q'}) {
    print "Quitting early as requested\n";
    exit(0);
  }

  $self->MyAnnotator(Eolas::Annotator->new);
  foreach my $entry ($self->MyWikiClient->Entries->Values) {
    $self->MyAnnotator->PhraseDict->{lc($entry->Title)} = 1;
  }

  # $self->MyWikiClient->Entries->Save;

  foreach my $entry (sort {$a->Title cmp $b->Title} $self->MyWikiClient->Entries->Values) {
    # $entry->Checkout;
    $entry->Compose;
    $entry->Commit
      (
       AutoApprove => exists $conf->{'-a'},
       SkipIfFileExists => exists $conf->{'--siee'},
       Skip => $conf->{'-s'},
      );
    $entry->PrettyPrint;
    print ("="x76);
    print "\n\n";
  }
}

sub ProcessURI {
  my ($self,%args) = @_;
  my $uri = $args{URI};
  $self->Cacher->get($uri);
  my $contents = $self->Cacher->content();

  # okay, first we cache this page in our file cache
  # make sure our personal cache has this

  # create the page for it
  $self->AddPage
    (
     URI => $uri,
     Contents => $contents,
    );

  # extract the text
  my $res = $self->MyToText->ToText(String => $contents);

  if (exists $res->{Success}) {
    my $text = $res->{Text};
    my $results = $self->MyTextAnalysis->AnalyzeText
      (Text => $text);
    $self->TAResults->{$uri} = $results;

    # now we have to analyze these results, just use the semantic output for starters
    my $hash = $results->{SemanticAnnotation}->[0]->{CalaisSimpleOutputFormat};
    foreach my $key (keys %$hash) {
      my $item = $hash->{$key};
      if (ref $item eq "ARRAY") {
	foreach my $entry (@{$hash->{$key}}) {
	  $self->AddEntity
	    (
	     URI => $uri,
	     HTML => $contents,
	     Text => $text,
	     Title => $entry->{content},
	     Normalized => $entry->{normalized},
	     Type => $key,
	    );
	}
      } elsif (ref $item eq "HASH") {
	$self->AddEntity
	  (
	   URI => $uri,
	   HTML => $contents,
	   Text => $text,
	   Title => $item->{content},
	   Normalized => $item->{normalized},
	   Type => $key,
	  );
      }
    }
  }
}

sub AddPage {
  my ($self,%args) = @_;
  if (! exists $self->MyWikiClient->Entries->Contents->{$args{URI}}) {
    my $entry = RB::Wiki::Entry::Page->new
      (
       Title => $args{URI},
       Server => $self->MyWikiClient->MyServer,
      );
    $self->MyWikiClient->Entries->Add
      ($args{URI} => $entry);
  }
}


sub AddEntity {
  my ($self,%args) = @_;
  # first we have to standardize the title
  my $title = $args{Title};
  return unless (defined $title and $title =~ /\S/);
  $title =~ s/\n/ /g;
  $title =~ s/\s+/ /g;
  my $entry;
  if (! exists $self->MyWikiClient->Entries->Contents->{$title}) {
    $entry = RB::Wiki::Entry::Entity->new
      (
       Title => $title,
       Server => $self->MyWikiClient->MyServer,
      );
    $self->MyWikiClient->Entries->Add
      ($title => $entry);
  } else {
    $entry = $self->MyWikiClient->Entries->Contents->{$title};
  }

  # add the entity type
  if (exists $args{Type}) {
    my $type = $args{Type};
    my $title2 = $type." (entity type)";
    my $entry2;
    if (! exists $self->MyWikiClient->Entries->Contents->{$title2}) {
      $entry2 = RB::Wiki::Entry::EntityType->new
	(
	 Title => $title2,
	 Server => $self->MyWikiClient->MyServer,
	);
      $self->MyWikiClient->Entries->Add
	($title2 => $entry2);
    } else {
      $entry2 = $self->MyWikiClient->Entries->Contents->{$title2};
    }
    $entry->Categories->{"Entity-type-".$type} = 1;
    $entry->EntityTypes->{$title2} = 1;
    $entry2->Entities->{$title} = 1;
  }

  $entry->ContainingPages->{$args{URI}} =
    RB::Wiki::Entry::Entity::ContainingPage->new
	(
	 Entity => $title,
	 URI => $args{URI},
	);

  # now add this title to the titles of this page
  $self->MyWikiClient->Entries->Contents->{$args{URI}}->Entities->{$title} = 1;
}

sub Wikiize {
  my ($self,$text) = @_;
  return $self->MyAnnotator->Annotate
    (Text => $text);
}

sub DoFactExtraction {
  my ($self,%args) = @_;
  my $results = FactExtraction
    (
     Sayer => $self->MySayer,
     Sentences => $args{Sentences},
    );
  return {
	  Target => Capability::FactExtraction::Process
	  (
	   Topic => $args{Topic},
	   Results => $results,
	  ),
	 };
}

1;
