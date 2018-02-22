#!/usr/bin/perl -w

use Data::Dumper;
use File::Stat;

foreach my $f (split /\n/, `find /usr/share/perl5`) {
  if (-f $f) {
    my $res = `ls -al "$f"`;
    if ($res =~ /andrewd/) {
      print $f."\n";
    }
  }
}
