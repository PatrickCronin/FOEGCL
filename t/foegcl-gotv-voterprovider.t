use Modern::Perl;

{
    package Test::FOEGCL::GOTV::VoterProvider;
    
    BEGIN { chdir 't' if -d 't' }
    use lib '../lib', 'lib';
    use Moo;
    extends 'FOEGCLModuleTestTemplate';    
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Test::Differences;
    use Readonly;
    
    Readonly my $TEST_VOTER_DATAFILE => 'voterprovider-test-datafile.csv';

    has _datafile => ( is => 'ro', isa => Str, builder => 1 );    
    has _voter_provider => (
        is => 'rw',
        isa => InstanceOf[ 'FOEGCL::GOTV::VoterProvider' ],
    );
    
    around _build__module_name => sub {
        return 'FOEGCL::GOTV::VoterProvider';
    };
    
    sub _build__datafile {
        return $TEST_VOTER_DATAFILE;
    }
    
    after _check_prereqs => sub {
        my $self = shift;
        
        # Ensure the testing datafile exists
        if (! -e $TEST_VOTER_DATAFILE) {
            plan(skip_all => "The testing datafile can't be found at " . path($TEST_VOTER_DATAFILE)->absolute);
        }
    };
    
    around _test_instantiation => sub {
        my $orig = shift;
        my $self = shift;
        
        my $voter_provider = new_ok( $self->_module_name => [
            datafile => $TEST_VOTER_DATAFILE,
        ] );
        plan(skip_all => 'Failed to instantiate the ' . $self->_module_name . ' object')
            unless ref $voter_provider eq 'FOEGCL::GOTV::VoterProvider';
            
        $self->_voter_provider($voter_provider);
    };
    
    around _test_usage => sub {
        my $orig = shift;
        my $self = shift;
        
        $self->_test_first_voter;
        $self->_test_second_voter;        
        
        my $record_count = 2;
        while ($self->_voter_provider->next_record) {
            $record_count++;
        }
        is($record_count, 100, 'found correct number of voters');
    };
    
    sub _test_first_voter {
        my $self = shift;
        
        my $first_voter = $self->_voter_provider->next_record;
        isa_ok($first_voter, 'FOEGCL::GOTV::Voter');

        eq_or_diff(
            {
                voter_registration_id => $first_voter->voter_registration_id,
                first_name => $first_voter->first_name,
                last_name => $first_voter->last_name,
                street_address => $first_voter->street_address,
                zip => $first_voter->zip,
            },
            {
                voter_registration_id => '342581988',
                first_name => 'Joshua',
                last_name => 'Gomez',
                street_address => '72127 Norway Maple',
                zip => '12144',
            },
            'first voter extracted correctly'   
        );
            
    }
    
    sub _test_second_voter {
        my $self = shift;
        
        my $second_voter = $self->_voter_provider->next_record;
        isa_ok($second_voter, 'FOEGCL::GOTV::Voter');

        eq_or_diff(
            {
                voter_registration_id => $second_voter->voter_registration_id,
                first_name => $second_voter->first_name,
                last_name => $second_voter->last_name,
                street_address => $second_voter->street_address,
                zip => $second_voter->zip,
            },
            {
                voter_registration_id => '1052372292',
                first_name => 'Eugene',
                last_name => 'Scott',
                street_address => '1486 Starling 989',
                zip => '12144',
            },
            'second voter extracted correctly'
        );

    }

}

Test::FOEGCL::GOTV::VoterProvider->new->run;