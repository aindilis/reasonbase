#!/usr/bin/perl -w

use BOSS::Config;

use Data::Dumper;

my $config = BOSS::Config->new
  (ConfFile => "/etc/myfrdcsa/config/reasonbase.conf");

print Dumper($config);
