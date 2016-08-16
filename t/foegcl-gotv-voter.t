use Modern::Perl;

{
    package Test::FOEGCL::GOTV::Voter;
    
    BEGIN { chdir 't' if -d 't' }
    use lib '../lib', 'lib';
    use Moo;
    extends 'FOEGCLModuleTestTemplate';
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Test::Exception;
    use Readonly;
    
    Readonly::Array my @TEST_VOTERS => (
        {
            voter_registration_id => 30015588441,
            first_name => 'Kimya',
            last_name => 'Dawson',
            street_address => '9 Charlotte Pl',
            zip => '28183',
        },
        {
            voter_registration_id => 1978022514,
            first_name => 'Phyllis',
            last_name => 'Stoffels',
            street_address => '42 Main St.',
            zip => '44442',
        }
    );
    
    around _build__module_name => sub {
        return 'FOEGCL::GOTV::Voter';
    };
    
    around _test_instantiation => sub {
        my $orig = shift;
        my $self = shift;
        
        my $friend = new_ok( $self->_module_name => [ %{ $TEST_VOTERS[0] } ] );
        plan(skip_all => "Failed to instantiate the " . $self->_module_name . " object")
            unless ref $friend eq $self->_module_name;
    };
    
    around _test_usage => sub {
        my $orig = shift;
        my $self = shift;
        
        foreach my $voter (@TEST_VOTERS) {
            $self->_test_voter($voter);
        }
        
        $self->_test_stringify;
    };
    
    sub _test_voter {
        my $self = shift;
        my $voter_fields = shift;
        
        my $voter = FOEGCL::GOTV::Voter->new(%$voter_fields);
        foreach my $field (keys %$voter_fields) {
            is($voter->$field, $voter_fields->{$field}, "$field attribute sets and gets");
        }
    }
    
    sub _test_stringify {
        my $self = shift;
     
        my $voter = FOEGCL::GOTV::Voter->new(%{ $TEST_VOTERS[0] });
        my $stringified = can_ok($voter, 'stringify');
        ok(length($stringified) > 0, 'stringifies ok');
    }
}

Test::FOEGCL::GOTV::Voter->new->run;