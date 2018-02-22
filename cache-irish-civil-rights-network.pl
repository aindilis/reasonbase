#!/usr/bin/perl -w

use Eolas;

use Data::Dumper;

my $sub1 = sub {
  my ($self,%args) = @_;
  my @uris;
  my $uri = "http://devel.irish-civil-rights-network.org/static/downloads/US-PROJECT-num-1.htm";
  $self->Cacher->credentials( 'fionnbarra', '8kocColvefKi' );
  $self->Cacher->get( $uri );
  push @uris, $uri;
  return \@uris;
};

my $sub2 = sub {
  my ($self,%args) = @_;
  my @uris;
  my $uri = "file:///var/lib/myfrdcsa/codebases/internal/reasonbase/data/files/Untitled.txt";
  push @uris, $uri;
  return \@uris;
};

$UNIVERSAL::eolas = Eolas->new
  (
   URIsFunction => $sub2,
   DBName => "sayer_eolas",
  );

$UNIVERSAL::eolas->Execute();
