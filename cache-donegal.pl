#!/usr/bin/perl -w

use Eolas;

use Data::Dumper;

my $sub1 = sub {
  my ($self,%args) = @_;

  my @uris;
  require PerlLib::Cacher;

  my $cacher = PerlLib::Cacher->new();
  $cacher->get("http://www.dun-na-ngall.com/news.html");

  my @list;
  foreach my $link ($cacher->links) {
    my $url = $link->url_abs->as_string;
    if ($url =~ /nw(\d+)\.html$/) {
      push @list, $url;
    }
  }

  push @uris, reverse @list;
  return \@uris;
};

$UNIVERSAL::eolas = Eolas->new
  (
   URIsFunction => $sub1,
   DBName => "sayer_eolas",
  );

$UNIVERSAL::eolas->Execute();
