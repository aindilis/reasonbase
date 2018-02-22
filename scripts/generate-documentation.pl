#!/usr/bin/perl -w

use RB::Wiki::Client;
use Text::Wrap;

$initial_tab = "";		# Tab before first line
$subsequent_tab = "";		# All other lines flush left

my $wc = RB::Wiki::Client->new
  (Host => "wiki.onshore.com",
   Username => "andrewd",
   Password => "spandex!");

my $titles =
  [
   "<REDACTED>",
  ];

exit(0);
$wc->AddTitles(Titles => $titles);

my @contents;
my $entries = {};
foreach my $entry ($wc->Entries->Values) {
  # $entry->Checkout;
  $entries->{$entry->Title} = $entry->Text->Contents;
}
foreach my $title (@$titles) {
  $entries->{$title} =~ s/\n\n+/\n\n/g;
  print $title."\n\n";
  my $t = $entries->{$title};
  if ($t) {
    $t =~ s/\[\[//g;
    $t =~ s/\]\]//g;
    print wrap($initial_tab, $subsequent_tab, ($t))."\n";
  }
  print ("="x76);
  print "\n\n";
}
