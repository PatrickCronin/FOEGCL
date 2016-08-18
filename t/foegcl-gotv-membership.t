use Modern::Perl;

{
    package Test::FOEGCL::GOTV::Membership;
    
    BEGIN { chdir 't' if -d 't' }
    use lib '../lib', 'lib';
    use Moo;
    extends 'FOEGCLModuleTestTemplate';
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Test::Differences;

    has _friends => ( is => 'ro', isa => ArrayRef[ InstanceOf[ 'FOEGCL::GOTV::Friend' ] ], lazy => 1, builder => 1 );
    
    sub _build__friends {
        my $self = shift;
        
        my @row_hrefs = $self->_read_data_csv(qw(
            friend_id
            first_name
            last_name
            street_address
            zip
            registered_voter
        ));
        
        return [
            map { FOEGCL::GOTV::Friend->new( %$_ ) } @row_hrefs
        ];
    }

    around _build__module_under_test => sub {
        return 'FOEGCL::GOTV::Membership';
    };
    
    after _check_prereqs => sub {
        my $self = shift;
        
        # Ensure the FOEGCL::GOTV::Friend module can be used
        if (! eval 'use FOEGCL::GOTV::Friend; 1' && $@) {
           plan(skip_all => "Can't use FOEGCL::GOTV::Friend!"); 
        }
    };
    
    around _test_methods => sub {
        my $orig = shift;
        my $self = shift;
        
        subtest $self->_module_under_test . '->has_registered_voter' => sub {
            $self->_test_method_has_registered_voter
        };
        
        subtest $self->_module_under_test . '->registered_voter_friends' => sub {
            $self->_test_method_registered_voter_friends
        };
    };
    
    around _default_object_args => sub {
        my $orig = shift;
        my $self = shift;
        
        return (
            membership_id => $self->_friends->[0]->friend_id,
            friends => [ @{ $self->_friends }[ 0, 1 ] ]
        );
    };    
    
    sub _test_method_has_registered_voter {
        my $self = shift;

        my $membership = $self->_module_under_test->new( $self->_default_object_args );
        can_ok($membership, 'has_registered_voter');
        plan (skip_all => $self->_module_under_test . " can't has_registered_voter!") if
            ! $membership->can('has_registered_voter');

        # Ensure the default membership does have a registered voter
        is($membership->has_registered_voter, 1, 'default membership has a registered voter');
        
        # Ensure the second membership does not have a registered voter
        $membership = $self->_module_under_test->new(
            membership_id => $self->_friends->[2]->friend_id,
            friends => [ $self->_friends->[2] ]
        );
        isnt($membership->has_registered_voter, 1, 'second membership does not have a registered voter');
        
        # Ensure the third membership does have a registered voter
        $membership = $self->_module_under_test->new(
            membership_id => $self->_friends->[3]->friend_id,
            friends => [ $self->_friends->[3] ]
        );
        is($membership->has_registered_voter, 1, 'third membership has a registered voter');
    }
    
    sub _test_method_registered_voter_friends {
        my $self = shift;

        my $membership = $self->_module_under_test->new( $self->_default_object_args );
        can_ok($membership, 'registered_voter_friends');
        plan (skip_all => $self->_module_under_test . " can't registered_voter_friends!") if
            ! $membership->can('registered_voter_friends');
        
        # Ensure the default membership has the correct registered voter friend
        eq_or_diff($membership->registered_voter_friends, [ $self->_friends->[1] ], 'default membership has correct registered voter friend');
        
        # Ensure the second membership has no registered voter friends
        $membership = $self->_module_under_test->new(
            membership_id => $self->_friends->[2]->friend_id,
            friends => [ $self->_friends->[2] ]
        );
        eq_or_diff($membership->registered_voter_friends, [], 'second membership does not have registered voter friends');
        
        # Ensure the third membership has the correct registered voter friend
        $membership = $self->_module_under_test->new(
            membership_id => $self->_friends->[3]->friend_id,
            friends => [ $self->_friends->[3] ]
        );
        eq_or_diff($membership->registered_voter_friends, [ $self->_friends->[3] ], 'third membership has correct registered voter friend');
    }
}

Test::FOEGCL::GOTV::Membership->new->run;

# friend_id, first_name, last_name, street_address, zip, registered_voter
__DATA__
288492,Herbert,Cornelia,418 Broadway,12207,0
288492,Ella,Fitzgerald,9271 132 Street,10013,1
492814,Steve,McFitz,1 Infinite Loop,90210,0
820102010482,Brenda,Fassie,818 Groetberg Strasse,4821,1
