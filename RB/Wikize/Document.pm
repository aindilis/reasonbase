package RB::Wikize::Document;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / File Text Entries /

  ];

sub init {
  my ($self,%args) = @_;
  $self->File($args{File});
}

sub Load {
  my ($self,%args) = @_;
  if (-f $self->File) {
    my $f = $self->File;
    my $c = `cat "$f"`;
    $self->Text($c);
  } else {
    $self->Text($args{Text});
  }
}

sub Method {
  my ($self,%args) = @_;

}

1;
