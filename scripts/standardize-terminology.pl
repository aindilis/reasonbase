#!/usr/bin/perl -w

# get a list of all pages and use this to add links where possible and or necessary

# standardize capitalization, spelling, terminology, etc for a system

# control over things like acronyms

foreach my $file (split /\n/, `find /var/lib/myfrdcsa/codebases/internal/reasonbase/data`) {
  if (-f $file) {
    if ($file !~ /\/[\.\#]/ and $file !~ /\~$/) {
      StandardizeFile(File => $file);
    }
  }
}

sub StandardizeFile {
  my %args = @_;
  my $file = $args{File};

  # we want to be able to take this file and look at its contents,
  # and then

  print "$file\n";
}
