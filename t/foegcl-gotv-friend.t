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
    
    Readonly::Array my @TEST_FRIENDS => (
        {
            friend_id => 288492,
            first_name => 'Herbert',
            last_name => 'Cornelia',
            street_address => '418 Broadway',
            zip => '12207',
            registered_voter => 0,
        },
        {
            friend_id => 48201,
            first_name => 'Ella',
            last_name => 'Fitzgerald',
            street_address => '9271 132nd Street',
            zip => 10013,
            registered_voter => 1,
        }
    );
    
    around _build__module_name => sub {
        return 'FOEGCL::GOTV::Friend';
    };
    
    around _test_instantiation => sub {
        my $orig = shift;
        my $self = shift;
        
        my $friend = new_ok( $self->_module_name => [ %{ $TEST_FRIENDS[0] } ] );
        plan(skip_all => "Failed to instantiate the " . $self->_module_name . " object")
            unless ref $friend eq $self->_module_name;
    };
    
    around _test_usage => sub {
        my $orig = shift;
        my $self = shift;
        
        foreach my $friend (@TEST_FRIENDS) {
            $self->_test_friend($friend);
        }
        
        $self->_test_stringify;
    };
    
    sub _test_friend {
        my $self = shift;
        my $friend_fields = shift;
        
        my $friend = FOEGCL::GOTV::Friend->new(%$friend_fields);
        foreach my $field (keys %$friend_fields) {
            is($friend->$field, $friend_fields->{$field}, "$field attribute sets and gets");
        }
    }
    
    sub _test_stringify {
        my $self = shift;
     
        my $friend = FOEGCL::GOTV::Friend->new(%{ $TEST_FRIENDS[0] });
        my $stringified = can_ok($friend, 'stringify');
        ok(length($stringified) > 0, 'stringifies ok');
    }
}

Test::FOEGCL::GOTV::Friend->new->run;