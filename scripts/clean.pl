#!/usr/bin/perl -w

use Data::Dumper;

my $e = eval `cat data`;

my $rel = {};
foreach my $l (@$e) {
  foreach my $line (split /\n/,$l->[1]) {
    my $s = [split /\s+/, $line];
    $rel->{$l->[0]}->{$s->[4]}->{ROOT} = $s->[1];
    $rel->{$l->[0]}->{$s->[4]}->{$s->[5]} = $s->[7];
  }
}

# print Dumper($rel);

foreach my $s (keys %$rel) {
  print "$s\n(and\n";
  foreach my $i (keys %{$rel->{$s}}) {
    my @t;
    push @t, $rel->{$s}->{$i}->{ROOT};
    foreach my $arg (1..5) {
      if (exists $rel->{$s}->{$i}->{"ARG$arg"}) {
	push @t, $rel->{$s}->{$i}->{"ARG$arg"};
      }
    }
    if (@t > 1) {
      print "\t(".join(" ",@t).")\n";
    }
  }
  print ")\n\n";
}
