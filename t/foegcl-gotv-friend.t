#!perl

use Modern::Perl;

{

    package Test::FOEGCL::GOTV::Friend;

    BEGIN { chdir 't' if -d 't' }
    use lib '../lib', 'lib';
    use Moo;
    extends 'FOEGCLModuleTestTemplate';
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Readonly;

    has _friends => ( is => 'ro', isa => ArrayRef [HashRef], builder => 1 );

    sub _build__friends {
        my $self = shift;

        my @row_hrefs = $self->_read_data_csv(
            qw(
              friend_id
              first_name
              last_name
              street_address
              zip
              registered_voter
              )
        );

        return \@row_hrefs;
    }

    around _build__module_under_test => sub {
        return 'FOEGCL::GOTV::Friend';
    };

    around _test_methods => sub {
        my $orig = shift;
        my $self = shift;

        subtest $self->_module_under_test . '->stringify' => sub {
            $self->_test_method_stringify;
        };
    };

    around _default_object_args => sub {
        my $orig = shift;
        my $self = shift;

        return %{ $self->_friends->[0] };
    };

    sub _test_method_stringify {
        my $self = shift;

        my $friend =
          $self->_module_under_test->new( $self->_default_object_args );
        my $stringified = can_ok( $friend, 'stringify' );
        plan( skip_all => $self->_module_under_test . q{ can't stringify!} )
          if !$friend->can('stringify');

        ok( length($stringified) > 0, 'stringifies ok' );

        return;
    }

    1;
}

Test::FOEGCL::GOTV::Friend->new->run;

# friend_id, first_name, last_name, street_address, zip, registered_voter
__DATA__
288492,Herbert,Cornelia,418 Broadway,12207,0
48201,Ella,Fitzgerald,9271 132 Street',10013,1
