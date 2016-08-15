use Modern::Perl;

{
    package Test::FOEGCL::GOTV::StreetAddress;
    use Moo;
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    
    sub run {
        done_testing();
    }
}

Test::FOEGCL::GOTV::StreetAddress->new->run;