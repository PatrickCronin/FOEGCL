use Modern::Perl;

{
    package Test::FOEGCL::GOTV::Friend;
    use Moo;
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    
    sub run {
        done_testing();
    }
}

Test::FOEGCL::GOTV::Friend->new->run;