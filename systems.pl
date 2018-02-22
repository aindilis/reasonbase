#!/usr/bin/perl -w

use WWW::Mediawiki::Client;

my $filename = 'Subject.wiki';
my $message = 'Testing';
my $mvs = WWW::Mediawiki::Client->new
  (
   host => 'caesar.l1nd.us'
  );

my $encoding = $mvs->encoding
  ("UTF8");

# like cvs update
$mvs->do_update($filename);

# like cvs commit
$mvs->commit_message("Test");
$mvs->do_commit($filename, $message);

#aliases
$mvs->do_up($filename);
$mvs->do_com($filename, $message);
