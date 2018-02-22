#!/usr/bin/perl -w

use Lingua::EN::Sentence qw(get_sentences);

# program to annotate text with logical fallacies

%fallacies = {
	      "AD-FIDENTIA" => "",
	      "AMBIGUOUS-COLLECTIVE" => "",
	      "ANTI-CONCEPTUAL-MENTALITY" => "",
	      "APPEAL-TO-IGNORANCE" => "",
	      "ARGUMENT-FROM-INTIMIDATION" => "",
	      "ARGUMENTUM-AD-POPULUM" => "",
	      "ARGUMENTUM-AD-VERECUNDIAM" => "",
	      "ASSUMPTION-CORRECTION-ASSUMPTION" => "",
	      "BAREFOOT" => "",
	      "BARKING-CAT" => "",
	      "BEGGING-THE-QUESTION" => "",
	      "BOOLEAN" => "",
	      "CHERISHING-THE-ZOMBIE" => "",
	      "DETERMINISM" => "",
	      "DISCARDED-DIFFERENTIA" => "",
	      "DONUT" => "",
	      "ECLECTIC" => "",
	      "ELEPHANT-REPELLENT" => "",
	      "EMPHATIC" => "",
	      "EXCLUSIVITY" => "",
	      "FALSE-ALTERNATIVE" => "",
	      "FALSE-ATTRIBUTION" => "",
	      "FALSIFIABILITY" => "",
	      "FALSIFIED-INDUCTIVE-GENERALIZATION" => "",
	      "FANTASY-PROJECTION" => "",
	      "FLAT-EARTH-NAVIGATION-SYNDROME" => "",
	      "FLOATING-ABSTRACTION" => "",
	      "FROZEN-ABSTRACTION" => "",
	      "GOVERNMENT-ABSOLUTIST" => "",
	      "GOVERNMENT-SOLIPOTENCE" => "",
	      "GRAVITY-GAME" => "",
	      "GREEK-MATH" => "",
	      "HOMILY-AD-HOMINEM" => "",
	      "I-CUBED" => "",
	      "IGNORING-HISTORICAL-EXAMPLE" => "",
	      "IGNORING-PROPORTIONALITY" => "",
	      "INSTANTIATION-OF-THE-UNSUCCESSFUL" => "",
	      "JOURNALISTIC/POLITICAL-FALLACIES" => "",
	      "MEATPOISON" => "",
	      "MEGATRIFLE" => "",
	      "MISPLACED-PRECISION" => "",
	      "MISSING-LINK" => "",
	      "MOVING-GOALPOST-SYNDROME" => "",
	      "NULL-VALUE" => "",
	      "OVERLOOKING-SECONDARY-CONSEQUENCES" => "",
	      "PIGEONHOLING" => "",
	      "PERFECTIONIST" => "",
	      "PRETENTIOUS" => "",
	      "PRETENTIOUS-ANTECEDENT" => "",
	      "PROOF-BY-SELECTED-INSTANCES" => "",
	      "PROVING-A-NEGATIVE" => "",
	      "RELATIVE-PRIVATION" => "",
	      "RETROGRESSIVE-CAUSATION" => "",
	      "SELECTIVE-SAMPLING" => "",
	      "SELF-EXCLUSION" => "",
	      "SHINGLE-SPEECH" => "",
	      "SILENCE-IMPLIES-CONSENT" => "",
	      "SIMPLISTIC-COMPLEXITY" => "",
	      "SPURIOUS-SUPERFICIALITY" => "",
	      "STOLEN-CONCEPT" => "",
	      "SUPRESSION-OF-THE-AGENT" => "",
	      "THOMPSON-INVISIBILITY-SYNDROME" => "",
	      "UNINTENDED-SELF-INCLUSION" => "",
	      "UNKNOWABLES" => "",
	      "VARIANT-IMAGIZATION" => "",
	      "VERBAL-OBLITERATION" => "",
	      "WOULDCHUCK" => "",
	     };

# split texts into senteces

foreach my $f (split /\n/, `ls data/corpus`) {
  my $c = `cat data/corpus/$f`;
  my $sentences = get_sentences($c); ## Get the sentences.
  foreach my $sentence (@$sentences) {

  }
}
