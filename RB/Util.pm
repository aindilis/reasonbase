package RB::Util;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw ( LinkToProject LinkToCachedURI GetCachedURI LinkToOriginalURI );

sub LinkToProject {
  my $project = shift;
  return "<a href=\"$UNIVERSAL::baseuri?project=$project\">$project</a>";
}

sub GetCachedURI {
  my ($project,$link,$number) = @_;
  if (defined $number) {
    return "$UNIVERSAL::baseuri?project=$project&uri=$link&number=$number";
  } else {
    return "$UNIVERSAL::baseuri?project=$project&uri=$link";
  }
}
sub LinkToCachedURI {
  my ($project,$link) = @_;
  return "<a href=\"".GetCachedURI($project,$link)."\">$link</a>";
}

sub LinkToOriginalURI {
  my ($link) = @_;
  return "<a href=\"$link\">$link</a>";
}

1;
