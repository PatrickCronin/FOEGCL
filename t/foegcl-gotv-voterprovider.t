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
    
    around _build__module_under_test => sub {
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
        
        $self->_voter_provider( $self->$orig );
    };
    
    around _test_methods => sub {
        my $orig = shift;
        my $self = shift;
        
        subtest $self->_module_under_test . '->next_record' => sub {
            $self->_test_method_next_record
        };
    };
    
    around _default_object_args => sub {
        my $orig = shift;
        my $self = shift;
        
        return (
            datafile => $self->_datafile
        );
    };
    
    sub _test_method_next_record {
        my $self = shift;
        
        can_ok($self->_voter_provider, 'next_record');
        plan (skip_all => $self->_module_under_test . " can't next_record!") if
            ! $self->_voter_provider->can('next_record');
        
        $self->_test_first_voter;
        $self->_test_second_voter;        
        
        my $record_count = 2;
        while ($self->_voter_provider->next_record) {
            $record_count++;
        }
        is($record_count, 100, 'found correct number of voters');        
    }
    
    sub _test_first_voter {
        my $self = shift;
        
        my $first_voter = $self->_voter_provider->next_record;
        isa_ok($first_voter, 'FOEGCL::GOTV::Voter');

        eq_or_diff(
            {
                $self->_extract_attrs( $first_voter, $self->_voter_attrs )
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
                $self->_extract_attrs( $second_voter, $self->_voter_attrs )
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
    
    sub _voter_attrs {
        return qw( voter_registration_id first_name last_name street_address zip );
    }

}

Test::FOEGCL::GOTV::VoterProvider->new->run;