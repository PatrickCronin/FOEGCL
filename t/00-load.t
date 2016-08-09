#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 5;

BEGIN {
    use_ok( 'FOEGCL::CSVProvider' ) || print "Bail out!\n";
    use_ok( 'FOEGCL::GOTV::MembershipProvider' ) || print "Bail out!\n";
    use_ok( 'FOEGCL::GOTV::VoterProvider' ) || print "Bail out!\n";
    use_ok( 'FOEGCL::GOTV::Voter' ) || print "Bail out!\n";
    use_ok( 'FOEGCL::GOTV::Friend' ) || print "Bail out!\n";
}

diag( "Testing FOEGCL::CSVProvider $FOEGCL::CSVProvider::VERSION, Perl $], $^X" );
