#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

unless ( $ENV{RELEASE_TESTING} ) {
    plan( skip_all => "Author tests not required for installation" );
}

my $min_tcm = 0.9;

plan skip_all => "Test::CheckManifest $min_tcm required" if
  ## no critic (ProhibitStringyEval)
  !eval " use Test::CheckManifest $min_tcm; 1";
## use critic

ok_manifest(
    {
        exclude => ['/.git/']
    }
);
