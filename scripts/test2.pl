#!/usr/bin/perl -w

use Data::Dumper;

my %escapes;
for (0..255) {
    $escapes{chr($_)} = sprintf("%%%02X", $_);
}

print Dumper(\%escapes);


