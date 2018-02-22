package Eolas::Annotator;

use PerlLib::MySQL;

use Data::Dumper;
use Lingua::EN::Tagger;
use Net::Dict;
use Text::InHTML;
use URI::Escape;


use Class::MethodMaker new_with_init => 'new',
  get_set =>
  [

   qw / Actions PhraseDict MyTagger MyMySQL /

  ];

sub init {
  my ($self,%args) = @_;
  $self->PhraseDict({});
  $self->MyTagger(Lingua::EN::Tagger->new(stem => 0));
  $self->Actions
    ({
      0 => sub {
        return
          {
           Link => "http://caesar.l1nd.us",
          }
        },
      1 => sub {
        my %args = @_;
        return {
		Link => ucfirst $args{Phrase},
		Type => "internal",
	       };
      },
      3 => sub {
        my %args = @_;
        my $wikiurl = $UNIVERSAL::eolas->WikiConfig->{BaseURI}; # "http://192.168.1.100/wiki1/index.php";
        my $p = $args{Phrase};
        $p =~s/\s+/_/g;
        return {Link => "$wikiurl/$p"};
      },
#       2 => sub {
#         my %args = @_;
#         my $baseuri = "http://posithon.org/pweb/cgi-bin/pweb.cgi";
#         return {Link => "$baseuri?term=".uri_escape($args{Phrase})};
#       },
     });
}

sub Annotate {
  my ($self,%args) = @_;
  my $text = $args{Text};

  # now window over the text rewriting it
  my @triplets;
  my @tmp = $text =~ /(\s*)(\S+)(\s*)/g;
  while (@tmp) {
    push @triplets, [splice @tmp, 0,3];
  }
  my @window;
  my @gramsets;
  my $count = 0;
  my $tokens = [];
  my $k = 0;
  my @tmp1 = @triplets;
  while (@tmp1) {
    $tokens->[$k++] = [];
    my $item = shift @tmp1;
    push @window, [$item,$count++];
    if (@window > 5) {
      shift @window;
    }
    my @grams;
    foreach my $i (0..$#window) {
      my @tmp;
      foreach my $j ($i..$#window) {
        push @tmp, $window[$j];
      }
      push @grams, \@tmp;
    }
    push @gramsets, \@grams;
    if ($item->[2] !~ /^\s+$/) {
      @window = ();
    }
  }

  foreach my $gramset (@gramsets) {
    foreach my $gram (@$gramset) {
      my @train;
      foreach my $w (@$gram) {
        push @train, @{$w->[0]};
      }
      pop @train;
      my $example = join('', @train);
      if ($self->DictionaryTest(Phrase => $example)) {
        my $a = $tokens->[$gram->[0]->[1]];
        my $sub = $self->Actions->{$self->PhraseDict->{lc($example)} || "0"};
	my $res = $sub->(Phrase => $example);
        my $link = $res->{Link};
        # $a->[0] = "<a href=\"$link\">{</a>".($a->[0] || "");
	if ($res->{Type} eq "internal") {
	  $a->[0] = "[[$link|{]] ".($a->[0] || "");
	} else {
	  $a->[0] = "[$link {] ".($a->[0] || "");
	}
        my $b = $tokens->[$gram->[$#gram]->[1]];
        $b->[1] .= " } ";
      }
    }
  }

  my $i = 0;
  my @stream;
  foreach my $triplet (@triplets) {
    if (1) {
      push @stream, $triplet->[0];
      push @stream, $tokens->[$i]->[0] if $tokens->[$i]->[0];
      push @stream, $triplet->[1];
      push @stream, $tokens->[$i]->[1] if $tokens->[$i]->[1];
      push @stream, $triplet->[2];
    } else {
      push @stream, Text::InHTML::encode_plain($triplet->[0]);
      push @stream, $tokens->[$i]->[0] if $tokens->[$i]->[0];
      push @stream, Text::InHTML::encode_plain($triplet->[1]);
      push @stream, $tokens->[$i]->[1] if $tokens->[$i]->[1];
      push @stream, Text::InHTML::encode_plain($triplet->[2]);
    }
    ++$i;
  }
  return join("",@stream);
}

sub DictionaryTest {
  my ($self,%args) = @_;
  return exists $self->PhraseDict->{lc($args{Phrase})};
}

1;
