use Modern::Perl;

{
    package Test::FOEGCL;
    use Test::More;
    use Moo;
    
    sub run {
        pass("Nothing to test");
        
        done_testing();
    }
}

Test::FOEGCL->new->run;