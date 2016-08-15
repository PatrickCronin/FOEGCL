use Modern::Perl;

{
    package Test::FOEGCL::GOTV::MembershipProvider;
    BEGIN { chdir 't' if -d 't' }
    use lib '../lib';
    use Moo;
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Test::Differences;
    use Readonly;
    
    Readonly my $TEST_MEMBERSHIP_DATAFILE => 'membershipprovider-test-datafile.csv';

    has _datafile => ( is => 'ro', isa => Str, builder => 1 );    
    has _membership_provider => (
        is => 'rw',
        isa => InstanceOf[ 'FOEGCL::GOTV::MembershipProvider' ],
    );
    
    sub _build__datafile {
        return $TEST_MEMBERSHIP_DATAFILE;
    }

    sub run {
        my $self = shift;
        
        $self->_check_prereqs;
        $self->_test_instantiation;
        $self->_test_usage;
        
        done_testing();
    }
    
    sub _check_prereqs {
        my $self = shift;
    
        # Ensure the FOEGCL::GOTV::MembershipProvider module can be used
        if (! use_ok('FOEGCL::GOTV::MembershipProvider')) {
            plan(skip_all => 'Failed to use the FOEGCL::GOTV::MembershipProvider module');
        }
        
        # Ensure the testing datafile exists
        if (! -e $TEST_MEMBERSHIP_DATAFILE) {
            plan(skip_all => "The testing datafile can't be found at " . path($TEST_MEMBERSHIP_DATAFILE)->absolute);
        }
    }
    
    sub _test_instantiation {
        my $self = shift;
        
        my $membership_provider = new_ok( 'FOEGCL::GOTV::MembershipProvider' => [
            datafile => $TEST_MEMBERSHIP_DATAFILE,
        ] );
        plan(skip_all => 'Failed to instantiate the FOEGCL::GOTV::MembershipProvider object')
            unless ref $membership_provider eq 'FOEGCL::GOTV::MembershipProvider';
            
        $self->_membership_provider($membership_provider);
    }
    
    sub _test_usage {
        my $self = shift;
        
        $self->_test_first_membership;
        $self->_test_second_membership;        
        
        my $valid_record_count = 2;
        while ($self->_membership_provider->next_record) {
            $valid_record_count++;
        }
        is($valid_record_count, 100, 'found correct number of valid memberships');
    }
    
    sub _test_first_membership {
        my $self = shift;
        
        my $first_membership = $self->_membership_provider->next_record;
        isa_ok($first_membership, 'FOEGCL::GOTV::Membership');
        is($first_membership->membership_id, 1, 'skipped invalid membership');
        
        my $friends = $first_membership->friends;
        is(scalar @$friends, 1, 'first membership has one friend');
        isa_ok($friends->[0], 'FOEGCL::GOTV::Friend');

        eq_or_diff(
            {
                friend_id => $friends->[0]->friend_id,
                first_name => $friends->[0]->first_name,
                last_name => $friends->[0]->last_name,
                street_address => $friends->[0]->street_address,
                zip => $friends->[0]->zip,
                registered_voter => $friends->[0]->registered_voter
            },
            {
                friend_id => '1',
                first_name => 'Steven',
                last_name => 'Porter',
                street_address => '38 Springs Road',
                zip => '12061',
                registered_voter => 0
            },
            'first membership friend extracted correctly'   
        );
            
    }
    
    sub _test_second_membership {
        my $self = shift;
        
        my $second_membership = $self->_membership_provider->next_record;
        isa_ok($second_membership, 'FOEGCL::GOTV::Membership');
        
        is ($second_membership->membership_id, 2, 'second membership has correct membership id');
        
        my $friends = $second_membership->friends;
        is(scalar @$friends, 2, 'second membership has two friends');
        isa_ok($friends->[0], 'FOEGCL::GOTV::Friend');
        isa_ok($friends->[1], 'FOEGCL::GOTV::Friend');
        
        eq_or_diff(
            {
                friend_id => $friends->[0]->friend_id,
                first_name => $friends->[0]->first_name,
                last_name => $friends->[0]->last_name,
                street_address => $friends->[0]->street_address,
                zip => $friends->[0]->zip,
                registered_voter => $friends->[0]->registered_voter
            },
            {
                friend_id => '2',
                first_name => 'Kathy',
                last_name => 'Carr',
                street_address => '073 Dennis Trail',
                zip => '12044',
                registered_voter => 1
            },
            'second membership first friend extracted correctly'
        );
        
        eq_or_diff(
            {
                friend_id => $friends->[1]->friend_id,            
                first_name => $friends->[1]->first_name,
                last_name => $friends->[1]->last_name,
                street_address => $friends->[1]->street_address,
                zip => $friends->[1]->zip,
                registered_voter => $friends->[1]->registered_voter
            },
            {
                friend_id => '2',
                first_name => 'Eugene',
                last_name => 'Carr',
                street_address => '073 Dennis Trail',
                zip => '12044',
                registered_voter => 1
            },
            'second membership second friend extracted correctly'
        );
    }

}

Test::FOEGCL::GOTV::MembershipProvider->new->run;
