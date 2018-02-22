package RB::Wikize;

# takes a set of texts and transforms them into a wiki.  obvious
# coextensive with coauthor.

# this system should use the "mvs" client in order to post to and remove from the wiki

# general process

# identify concepts in text and organize those concepts into a wiki format namely

# interface this stuff with CLEAR, study and with text to knowledge formation stuff

use PerlLib::Collection;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / FileList Entries /

  ];

sub init {
  my ($self,%args) = @_;
  $self->FileList($args{FileList} || []);
}

sub AddConceptTexts {
  my ($self,%args) = @_;
}

sub UpdateConceptIndex {
  my ($self,%args) = @_;
}

sub LoadFromWiki {
  my ($self,%args) = @_;
  # must be sensitive to any changes

  # use MVS client to do an extract on everything
}

sub ApproveAdditions {
  my ($self,%args) = @_;

}

sub ExtractKnowledge {
  my ($self,%args) = @_;
  # axiomatize various content, that hasn't been axiomatized

}


1;
