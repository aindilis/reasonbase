package RB::Wiki::Entry::Page;

use RB::Wiki::Entry;

our @ISA = qw(RB::Wiki::Entry);

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Entities /

  ];

sub init {
  my ($self,%args) = @_;
  $args{Categories} ||= {};
  foreach my $cat ("Auto-generated","Cached-page") {
    $args{Categories}->{$cat} = 1;
  }
  $self->Entities($args{Entities} || {});
  $self->RB::Wiki::Entry::init(%args);
}

sub Generate {
  my ($self,%args) = @_;
  my @contents;
  my @types;

  if (scalar %{$self->Entities}) {
    push @contents, "== Entities ==";
    foreach my $entity (sort keys %{$self->Entities}) {
      # link to the cached and the original
      push @contents, "[[$entity]]";
    }
  }

  $self->AddToGenerated(20,@contents);
  $self->RB::Wiki::Entry::Generate(%args);
}

1;
