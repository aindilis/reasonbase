#!/usr/bin/perl -w

use Eolas;

use Data::Dumper;

my $sub1 = sub {
  my ($self,%args) = @_;
  my @uris = ("http://ia360624.us.archive.org/0/items/PossibilityThinkingExplorationsInLogicAndThoughtByJustinMCoslor/words");
  return \@uris;
};

my $sub2 = sub {
  my ($self,%args) = @_;
  my $dir = "/var/lib/myfrdcsa/codebases/internal/picform/data/archive.org";
  my @uris;
  foreach my $file (split /\n/, `ls $dir/x*`) {
    push @uris, "file://$file";
  }
  return \@uris;
};

$UNIVERSAL::eolas = Eolas->new
  (
   URIsFunction => $sub2,
   DBName => "sayer_eolas",
  );

$UNIVERSAL::eolas->Execute();
