package RB::Wiki::Profile;

# an object to represent when a file has changed at all

use Data::Dumper;
use File::Stat;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / FQFN MyHash MyStat /

  ];

sub init {
  my ($self,%args) = @_;
  my $fqfn = $args{FQFN};
  $self->FQFN($fqfn);
  my $hash = `md5sum "$fqfn"`;
  my $stat = File::Stat->new($fqfn);
  $self->MyHash($hash);
  $self->MyStat($stat);
}

1;
