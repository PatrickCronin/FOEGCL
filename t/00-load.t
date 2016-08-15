#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 11;

BEGIN {
    use_ok( 'FOEGCL' ) || print "Bail out!\n";

    use_ok( 'FOEGCL::Logger' ) || print "Bail out!\n";
    use_ok( 'FOEGCL::GOTV::StreetAddress' ) || print "Bail out!\n";

    use_ok( 'FOEGCL::CSVProvider' ) || print "Bail out!\n";
    use_ok( 'FOEGCL::GOTV::MembershipProvider' ) || print "Bail out!\n";
    use_ok( 'FOEGCL::GOTV::VoterProvider' ) || print "Bail out!\n";
        
    use_ok( 'FOEGCL::GOTV::Friend' ) || print "Bail out!\n";
    use_ok( 'FOEGCL::GOTV::Membership' ) || print "Bail out!\n";
    use_ok( 'FOEGCL::GOTV::Voter' ) || print "Bail out!\n";

    use_ok( 'FOEGCL::ItemStore' ) || print "Bail out!\n";
    use_ok( 'FOEGCL::GOTV::VoterStore' ) || print "Bail out!\n";
}

diag( "Testing FOEGCL $FOEGCL::VERSION, Perl $], $^X" );
