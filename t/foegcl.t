use Modern::Perl;

{
    package Test::FOEGCL;
    
    BEGIN { chdir 't' if -d 't' }
    use lib '../lib', 'lib';
    use Moo;
    extends 'FOEGCLModuleTestTemplate';
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    
    around _build__module_name => sub {
        return 'FOEGCL';
    };
    
    around _test_usage => sub {
        pass("Nothing to test!");
    };
}

Test::FOEGCL->new->run;