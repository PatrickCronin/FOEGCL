use Modern::Perl;

{
    package Test::FOEGCL::GOTV::VoterStore;
    
    BEGIN { chdir 't' if -d 't' }
    use lib '../lib', 'lib';
    use Moo;
    extends 'FOEGCLModuleTestTemplate';
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    
    around _build__module_name => sub {
        return 'FOEGCL::GOTV::VoterStore';
    };
}

Test::FOEGCL::GOTV::VoterStore->new->run;