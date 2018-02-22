#!/usr/bin/perl -w

use Eolas;

use Data::Dumper;

my $sub1 = sub {
  my ($self,%args) = @_;
  my $dir = "/home/andrewdo/projects/dochartaigh/newsletters/www.odochartaigh.org/newsletters";
  my @uris;
  push @uris, (
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/cover36.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/cover37.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/cover38.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue01.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue02.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue03.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue04.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue05.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue06.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue07.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue08.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue09.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue10.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue11.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue12-p1-40.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue12-p41-80.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue13.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue14.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue15.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue16.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue17.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue18.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue19.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue20.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue22.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue23.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue24.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue25.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue26.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue27.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue28.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue29.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue30.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue31.htm",
	       "http://frdcsa.org/~andrewdo/projects/odochartaigh-newsletters_Dir/issue32.htm",
	      );

  foreach my $file (split /\n/, `ls $dir/*.txt`) {
    push @uris, "file://$file";
  }
  return \@uris;
};

$UNIVERSAL::eolas = Eolas->new
  (
   URIsFunction => $sub1,
   DBName => "sayer_eolas",
  );

$UNIVERSAL::eolas->Execute();
