#!/usr/bin/perl

use BOSS::Config;
use RB::Util;
use Sayer;

use Data::Dumper;
use String::ShellQuote;
use Text::InHTML;
use URI::Escape;
use Cache::FileCache;
use WWW::Mechanize::Cached;

$specification = "
	-p <project>		Project
	-u <uri>		URI
";

my $config = BOSS::Config->new
  (
   Spec => $specification,
   ConfFile => "/etc/myfrdcsa/config/reasonbase.conf",
  );

my $conf = $config->CLIConfig;

my $project = $conf->{'-p'} || "ODochartaigh";
my $uri = $conf->{'-u'};

if (! (defined $project)) {
  print "No project, exiting\n";
  exit(0);
}

my $projectinfo = $config->RCConfig->{Project};

print Dumper($projectinfo);

my $cacheargs;
if (exists $projectinfo->{$project}) {
  $cacheargs = $projectinfo->{$project};
} else {
  print "unknown project, exiting\n";
  exit(0);
}

my $cacheobj =
  Cache::FileCache->new
  ($cacheargs);

my $cacher =
  WWW::Mechanize::Cached->new
  (
   cache => $cacheobj,
   timeout => 15,
  );

my $filecache = $cacher->{"WWW::Mechanize::Cached"};

my $request;
foreach my $key ($cacheobj->get_keys) {
  if ($key =~ /ODochartaighNewsletter(\d+)\.txt/) {
    if ($key =~ /^GET (\S+)\s/) {
      my $cacheduri = $1;
      # remove from cache, and retrieve again
      print Dumper({
		    CachedURI => $cacheduri,
		    Key => $key,
		   });
      $filecache->remove($key);
      $cacher->get($cacheduri);
    }
  }
}

1;
