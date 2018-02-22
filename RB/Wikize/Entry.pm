package RB::Wikize::Entry;

# sample class

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Text Links KeyConcepts /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Attribute($args{Attribute} || "");
}

sub DraftStatus {
  my ($self,%args) = @_;
  # the quality of the text to be formalized, whether it is ready or
  # not

}

sub Axiomatize {
  my ($self,%args) = @_;
  # use text to knowledge formation tools to generate knowledge from
  # this text

}

1;
