#!/usr/bin/perl -w

use Eolas;

use Data::Dumper;

my $sub1 = sub {
  my ($self,%args) = @_;
  my @uris;
  my $uri = "http://www.tarawatch.org/";
  print "$uri\n";
  $self->Cacher->get( $uri );
  push @uris, $uri;
  my $i = 1;
  my $continue;
  do {
    ++$i;
    my $uri = "http://www.tarawatch.org/page/$i";
    print "$uri\n";
    $self->Cacher->get( $uri );
    # now, analyze the contents
    # do term extraction followed by PerlLib::TFIDF
    $continue = $self->Cacher->content() !~ /Sorry, but the page you requested cannot be found./;
    if ($continue) {
      push @uris, $uri;
    }
  } while ($continue);
  return \@uris;
};

my $sub2 = sub {
  my ($self,%args) = @_;
  my @uris;
  my $uri = "http://www.tarawatch.org/";
  print "$uri\n";
  $self->Cacher->get( $uri );
  push @uris, $uri;
  my $i = 1;
  my $continue;
  do {
    ++$i;
    my $uri = "http://www.tarawatch.org/page/$i";
    print "$uri\n";
    $self->Cacher->get( $uri );
    # now, analyze the contents
    # do term extraction followed by PerlLib::TFIDF
    $continue = $self->Cacher->content() !~ /Sorry, but the page you requested cannot be found./;
    if ($continue) {
      push @uris, $uri;
      # also add all external links
      foreach my $link ($self->Cacher->links) {
	my $uri2 = $link->url_abs->as_string;
	if ($uri2 ne "http://groups.yahoo.com/group/hilloftara/message/11797") {
	  push @uris, $uri2;
	}
      }
    }
  } while ($continue);
  return \@uris;
};

$UNIVERSAL::eolas = Eolas->new
  (
   URIsFunction => $sub1,
  );

$UNIVERSAL::eolas->Execute();
