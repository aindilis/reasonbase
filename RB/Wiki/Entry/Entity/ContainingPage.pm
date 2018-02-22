package RB::Wiki::Entry::Entity::ContainingPage;

use RB::Util;
use Text::InHTML;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Entity URI Matches  /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Entity($args{Entity});
  $self->URI($args{URI});

}

sub Generate {
  my ($self,%args) = @_;
  my $entity = $args{Entity};
  my $title = $entity->Title;
  my @results = "[".GetCachedURI($UNIVERSAL::eolas->Project,$self->URI)." Cached ".$self->URI."]";
  my $tokenized = $UNIVERSAL::eolas->TAResults->{$self->URI}->{Tokenization}->[0];
  # print $tokenized."\n";
  my @matches;
  my $i = 0;
  foreach my $line (split /\n/, $tokenized) {
    # print $line."\n";
    #     print Dumper(
    # 		 Line => $line,
    # 		 Title => $title,
    # 		);
    my $regex = $title;
    $regex =~ s/(\W)/\\$1/g;
    if ($line =~ /$regex/i) {
      push @matches, {
		      Line => $line,
		      Number => $i,
		     };
    }
    ++$i;
  }
  $self->Matches(\@matches);
  push @results, map {"* ".
			'['.GetCachedURI($UNIVERSAL::eolas->Project,$self->URI,$_->{Number})." ".$_->{Number}."] ".
			  $UNIVERSAL::eolas->Wikiize($_->{Line})} @matches;
  return join("\n", @results);
}

1;
