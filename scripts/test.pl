#!/usr/bin/perl -w

use Data::Dumper;
use HTTP::Request::Common;

my @pages = ('Spam Fighting in Outlook (2002/2003/XP)');

my $res = POST 'http://www.perl.org/survey.cgi',
  [
   pages => join("\n", @pages),
   action => 'submit',
   curonly => 'true',
  ];

$res->{'_content'} =~ s/\(/%28/g;
$res->{'_content'} =~ s/\)/%29/g;
print Dumper($res);
