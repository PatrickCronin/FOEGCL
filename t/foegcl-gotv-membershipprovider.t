#!perl

use Modern::Perl;

{

    package Test::FOEGCL::GOTV::MembershipProvider;

    use FindBin;
    use File::Spec::Functions qw( catdir catfile );
    use lib catdir( $FindBin::Bin, 'lib' );
    
    use Moo;
    extends 'FOEGCLModuleTestTemplate';
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Test::Differences;
    use Readonly;

    Readonly my $TEST_MEMBERSHIP_DATAFILE =>
      'membershipprovider-test-datafile.csv';

    has _datafile => ( is => 'ro', isa => Str, builder => 1 );
    has _membership_provider => (
        is  => 'rw',
        isa => InstanceOf ['FOEGCL::GOTV::MembershipProvider'],
    );

    around _build__module_under_test => sub {
        return 'FOEGCL::GOTV::MembershipProvider';
    };

    sub _build__datafile {
        return catfile( $FindBin::Bin, $TEST_MEMBERSHIP_DATAFILE );
    }

    after _check_prereqs => sub {
        my $self = shift;

        # Ensure the testing datafile exists
        if ( !-e $self->_datafile ) {
            plan( skip_all => q{The testing datafile can't be found at }
                  . $self->_datafile );
        }
    };

    around _test_instantiation => sub {
        my $orig = shift;
        my $self = shift;

        $self->_membership_provider( $self->$orig );
    };

    around _test_methods => sub {
        my $orig = shift;
        my $self = shift;

        subtest $self->_module_under_test . '->next_record' => sub {
            $self->_test_method_next_record;
        };
    };

    around _default_object_args => sub {
        my $orig = shift;
        my $self = shift;

        return ( datafile => $self->_datafile );
    };

    sub _test_method_next_record {
        my $self = shift;

        can_ok( $self->_membership_provider, 'next_record' );
        plan( skip_all => $self->_module_under_test . q{ can't next_record!} )
          if !$self->_membership_provider->can('next_record');

        $self->_test_first_membership;
        $self->_test_second_membership;

        my $valid_record_count = 2;
        while ( $self->_membership_provider->next_record ) {
            $valid_record_count++;
        }
        is(
            $valid_record_count,
            100,    ## no critic (ProhibitMagicNumbers)
            'found correct number of valid memberships'
        );

        return;
    }

    sub _test_first_membership {
        my $self = shift;

        my $first_membership = $self->_membership_provider->next_record;
        isa_ok( $first_membership, 'FOEGCL::GOTV::Membership' );
        is( $first_membership->membership_id, 1, 'skipped invalid membership' );

        my $friends = $first_membership->friends;
        is( scalar @{$friends}, 1, 'first membership has one friend' );
        isa_ok( $friends->[0], 'FOEGCL::GOTV::Friend' );

        eq_or_diff(
            { $self->_extract_attrs( $friends->[0], $self->_friend_attrs ) },
            {
                friend_id        => '1',
                first_name       => 'Steven',
                last_name        => 'Porter',
                street_address   => '38 Springs Road',
                zip              => '12061',
                registered_voter => 0
            },
            'first membership friend extracted correctly'
        );

        return;
    }

    sub _test_second_membership {
        my $self = shift;

        my $second_membership = $self->_membership_provider->next_record;
        isa_ok( $second_membership, 'FOEGCL::GOTV::Membership' );

        is( $second_membership->membership_id,
            2, 'second membership has correct membership id' );

        my $friends = $second_membership->friends;
        is( scalar @{$friends}, 2, 'second membership has two friends' );
        isa_ok( $friends->[0], 'FOEGCL::GOTV::Friend' );
        isa_ok( $friends->[1], 'FOEGCL::GOTV::Friend' );

        eq_or_diff(
            { $self->_extract_attrs( $friends->[0], $self->_friend_attrs ) },
            {
                friend_id        => '2',
                first_name       => 'Kathy',
                last_name        => 'Carr',
                street_address   => '073 Dennis Trail',
                zip              => '12044',
                registered_voter => 1
            },
            'second membership first friend extracted correctly'
        );

        eq_or_diff(
            { $self->_extract_attrs( $friends->[1], $self->_friend_attrs ) },
            {
                friend_id        => '2',
                first_name       => 'Eugene',
                last_name        => 'Carr',
                street_address   => '073 Dennis Trail',
                zip              => '12044',
                registered_voter => 1
            },
            'second membership second friend extracted correctly'
        );

        return;
    }

    sub _friend_attrs {
        return
          qw ( friend_id first_name last_name street_address zip registered_voter );
    }
}

Test::FOEGCL::GOTV::MembershipProvider->new->run;
