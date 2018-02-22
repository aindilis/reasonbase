package RB::Wiki::Entry::Entity;

use RB::Wiki::Entry;

our @ISA = qw(RB::Wiki::Entry);

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / EntityResolutions EntityTypes ContainingPages Matches /

  ];

sub init {
  my ($self,%args) = @_;
  $args{Categories} ||= {};
  foreach my $cat ("Auto-generated","Named entity") {
    $args{Categories}->{$cat} = 1;
  }

  $self->EntityResolutions($args{EntityResolutions} || {});
  $self->EntityTypes($args{EntityTypes} || {});
  $self->ContainingPages($args{ContainingPages} || {});

  # also add the <entity-type> category
  $self->RB::Wiki::Entry::init(%args);

  # add google images search for entities
  my $se = '%22'.join("+",split /\W/,$self->Title).'%22';
  $self->Links->{"http://www.google.com/search?hl=en&q=$se"} = "Search Google for ".$self->Title;
  $self->Links->{"http://images.google.com/images?hl=en&q=$se"} = "Search Google Images for ".$self->Title;
  $self->Matches({});
}

sub Generate {
  my ($self,%args) = @_;
  my @contents;
  my @types;

  if (%{$self->EntityResolutions}) {
    push @contents, "== Entity Resolutions ==";
    push @contents, "This entity resolves to the following other entities.";
    foreach my $resolution (sort keys %{$self->EntityResolutions}) {
      push @contents, "[[$resolution]]";
    }
  } else {
    # push @contents, "== Entity Resolutions ==";
    # push @contents, "This entity is not known to resolve to any other entity.";
  }

  if (0) {
    if (scalar %{$self->EntityTypes}) {
      push @contents, "== Entity Types ==";
      foreach my $type (sort keys %{$self->EntityTypes}) {
	# link to the cached and the original
	push @contents, "[[$type]]";
      }
    } else {
      # push @contents, "== Entity Types ==";
      # push @contents, "No known entity type.";
    }
  }

  push @contents, "== Containing Pages ==";
  if (scalar %{$self->ContainingPages}) {
    # sort by date
    foreach my $containingpage (sort {$a->URI cmp $b->URI} values %{$self->ContainingPages}) {
      push @contents, $containingpage->Generate
	(Entity => $self);
      foreach my $match (@{$containingpage->Matches}) {
	$self->Matches->{$match->{Line}} = 1;
      }
    }
  } else {
    push @contents, "No known containing pages.";
  }

  if (0) {
    print Dumper($self->Matches);
    my $result = $UNIVERSAL::eolas->DoFactExtraction
      (
       Sentences => [sort keys %{$self->Matches}],
       Topic => $self->Title,
      );
  }

  $self->AddToGenerated(20,@contents);
  $self->RB::Wiki::Entry::Generate(%args);
}

1;
