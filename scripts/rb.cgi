#!/usr/bin/perl

use BOSS::Config;
use RB::Util;
use Sayer;

use CGI qw/:standard *table start_ul/;
use Data::Dumper;
use String::ShellQuote;
use Text::InHTML;
use URI::Escape;

my $config = BOSS::Config->new
  (ConfFile => "/etc/myfrdcsa/config/reasonbase.conf");

my $baseuri = $config->RCConfig->{BaseURI};
my $projectinfo = $config->RCConfig->{Project};

my $string = $ENV{QUERY_STRING};

# Say(Dumper(\%ENV));

my $query = new CGI($string);

sub ExitMessage {
  my $message = shift;
  print p($message) if $message;
  print end_html;
  exit(0);
}

my $content;
my @content = $query->param('content');
if (scalar @content) {
  $content = shift @content;
}

my $project;
my @project = $query->param('project');
if (scalar @project) {
  $project = shift @project;
}

my $uri;
my @uri = $query->param('uri');
if (scalar @uri) {
  $uri = shift @uri;
}

my $number;
my @number = $query->param('number');
if (scalar @number) {
  $number = shift @number;
}

if ($content) {
  if (! (defined $project and defined $uri)) {
    ExitMessage;
  }
} else {
  print header,
    start_html('ReasonBase Cache System'),
      h1("<a href=\"$baseuri\">ReasonBase Cache System</a>"),
	hr();

  if (! defined $project) {
    print p(b("Projects"));
    print start_ul;
    foreach my $project (sort keys %$projectinfo) {
      # now we have to make a link
      print li(LinkToProject($project));
    }
    print end_ul;
    ExitMessage();
  }
}
my $cacheargs;
if (exists $projectinfo->{$project}) {
  $cacheargs = $projectinfo->{$project};
} else {
  ExitMessage("Unknown project.");
}

print p(b("Project").": ".LinkToProject($project));


use Cache::FileCache;
use WWW::Mechanize::Cached;

my $cacheobj =
  Cache::FileCache->new
  ($cacheargs);

if (! defined $uri) {
  # get a listing of all the pages in the cache
  my @list;
  foreach my $key ($cacheobj->get_keys) {
    # print p($key);
    if ($key =~ /^GET (\S+)\s/) {
      push @list, $1;
    }
  }
  print p(b("Cached Links"));
  print start_ul;
  foreach my $link (sort @list) {
    print li(LinkToCachedURI($project,$link));
  }
  print end_ul;
  ExitMessage();
}

# now we have our URI and our project

# we want to check the cache for this


# make sure URI is well formed
if (0) {			# ! WellFormedURI($uri)) {
  ExitMessage("Malformed URI.");
}

#GET http://www.tarawatch.org/ Accept-Encoding: gzip 

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

if (! defined $request) {
  ExitMessage("No matching cache key found.  \"Real Soon Now\" you will be able to request that this URI is added to this project.");
}

my $javascript = 1;

if ($content) {
  use WWW::Mechanize::Cached;
  my $cacher =
    WWW::Mechanize::Cached->new
	(
	 cache => $cacheobj,
	 timeout => 15,
	);

  $cacher->get($uri);

  if ($javascript) {
#     require KBS::Util;
#     my @hi = ("ho"); # split /\n/, header.$cacher->content5B
#     foreach my $line (@hi) {
#       print "<!-- Test -->\n"; # document.write($line\n)\n";
#     }
    print "<!-- This for some reason makes it work -->\n";
    print header;
    if ($uri =~ /\.txt$/i) {
      use Text::InHTML;
      if (0 and $number) {
 	print "Loading sentence data... may take a moment<p>\n";
 	my $host = $projectinfo->{$project}->{Wiki}->{Host};
 	my $file = "/var/lib/myfrdcsa/codebases/internal/reasonbase/data/servers/$host/$project.dat";
	use File::Slurp;
	$all_of_it = read_file($file);
	my $e = eval $all_of_it;
	my $tokenized = $e->{$uri}->{Tokenization}->[0];
	print Text::InHTML::encode_plain(Dumper($file));
	my $i = 0;
	print "<pre>\n";
	foreach my $line (split /\n/, $tokenized) {
	  print "<a name=\"$i\">";
	  my $text = Text::InHTML::encode_plain($line);
	  if ($i == $number) {
	    print "<font color=\"red\" bgcolor=\"#FAF8CC\">".$text."</font>";
	  } else {
	    print $text;
	  }
	  print "</a>\n";
	  ++$i;
	}
	print "</pre>\n";
      } else {
	print "<pre>\n".Text::InHTML::encode_plain($cacher->content)."</pre>\n";
      }
    } else {
      print $cacher->content;
    }
  } else {
    print header, $cacher->content;
  }
} else {
  print p(b("Cache Entry for URI: ".LinkToCachedURI($project,$uri)));
  print p(b("Original Page for URI: ".LinkToOriginalURI($uri)));
  print hr;
  my $numberstring = "";
  if ($number) {
    $numberstring = "\&number=$number#$number";
  }
  if ($javascript) {
    print "<IFRAME SRC=\"$baseuri?project=$project&content=1&uri=$uri$numberstring\" WIDTH=100% HEIGHT=1000></IFRAME>";
    #print "<script src=\"$baseuri?project=$project&content=1&uri=$uri\" type=\"text/javascript\"> </script>";
  } else {
    print "<!--#include VIRTUAL=\"$baseuri?project=$project&content=1&uri=$uri$numberstring\" -->";
  }
  print end_html;
}

1;

