package RB::Wiki::Client;

use Manager::Dialog qw(ApproveCommands Message);
use PerlLib::Collection;
use RB::Wiki::Entry;
use RB::Wiki::Server;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Entries MyServer / ];

sub init {
  my ($self,%args) = @_;
  $self->Entries
    (PerlLib::Collection->new
     (
      Type => "RB::Wiki::Entry",
      StorageFile => $args{StorageFile},
     ));
  $self->Entries->Contents({});
  $self->MyServer
    ($args{Server} ||
     RB::Wiki::Server->new
     (
      Client => $self,
      Host => $args{Host},
      Username => $args{Username},
      Password => $args{Password},
      Wiki => $args{Wiki},
      Project => $args{Project},
     ));
  $self->Login;
}

sub Login {
  my ($self,%args) = @_;
  return $self->MyServer->Login;
}

sub AddTitles {
  my ($self,%args) = @_;
  foreach my $title (@{$args{Titles}}) {
    my $entry = RB::Wiki::Entry->new
      (Title => $title,
       Server => $self->MyServer);
    $self->Entries->AddAutoIncrement
      (Item => $entry);
  }
}

sub CheckoutEntries {
  my ($self,%args) = @_;
  foreach my $entry (@{$args{Entries}}) {
    $entry->Checkout;
  }
}

sub UpdateEntries {
  my ($self,%args) = @_;
  foreach my $entry (@{$args{Entries}}) {
    # $entry->Update;
  }
}

1;
