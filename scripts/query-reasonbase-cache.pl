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

my $project = $conf->{'-p'};
my $uri = $conf->{'-u'};

if (! (defined $project and defined $uri)) {
  print "No project and uri, exiting\n";
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

my $request;
foreach my $key ($cacheobj->get_keys) {
  if ($key =~ /^GET (\S+)\s/) {
    my $cacheduri = $1;
    if ($cacheduri eq $uri) {
      $request = $key;
      last;
    }
  }
}

my $cacher =
  WWW::Mechanize::Cached->new
  (
   cache => $cacheobj,
   timeout => 15,
  );

# $cacher->get($uri);
print Dumper([keys %$cacher]);
my $filecache = $cacher->{"WWW::Mechanize::Cached"};
# print Dumper([$filecache->get_keys]);
# $filecache->clear();

# print Dumper([$filecache->get_keys]);
$cacher->get($uri);

print Dumper($cacher->content);

# print Dumper(ISCached => $cacher->is_cached());

print "<!-- This for some reason makes it work -->\n";
print header;
if ($uri =~ /\.txt$/i) {
  use Text::InHTML;
  print "<pre>\n".Text::InHTML::encode_plain($cacher->content)."</pre>\n";
} else {
  print $cacher->content;
}


1;

