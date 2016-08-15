use Modern::Perl;

{
    package Test::FOEGCL::CSVProvider;
    BEGIN { chdir 't' if -d 't' }
    use lib '../lib';
    use Moo;
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Test::Differences;
    use Test::Exception;
    use Path::Tiny;
    use Cwd;
    use Readonly;
    
    Readonly my $TEST_DATAFILE => 'csvprovider-test-datafile.csv';
    Readonly my $TEST_INVALID_DATAFILE => 'csvprovider-invalid-test-datafile.csv';

    sub run {
        my $self = shift;

        $self->_check_prereqs;
        $self->_test_instantiation;
        $self->_test_usage;
        done_testing();
    }

    sub _check_prereqs {
        my $self = shift;
    
        # Ensure the FOEGCL::CSVProvider module can be used
        if (! use_ok('FOEGCL::CSVProvider')) {
            plan(skip_all => 'Failed to use the FOEGCL::CSVProvider module');
        }
        
        # Ensure the testing datafile exists
        if (! -e $TEST_DATAFILE) {
            plan(skip_all => "The testing datafile can't be found at " . path($TEST_DATAFILE)->absolute);
        }
        
        # Ensure the invalid testing datafile doesn't exist
        if (-e $TEST_INVALID_DATAFILE
            && ! unlink $TEST_INVALID_DATAFILE) {
            plan(skip_all => "The invalid testing datafile shouldn't exist, and can't be deleted at " . path($TEST_INVALID_DATAFILE)->absolute);
        }
    }
    
    sub _test_instantiation {
        my $self = shift;
     
        my $csv = new_ok( 'FOEGCL::CSVProvider' => [
            datafile => $self->_csvprovider_datafile,
            columns => $self->_csvprovider_columns,
            skip_header => $self->_csvprovider_skip_header,
            parser_options => $self->_csvprovider_parser_options
        ] );
        plan(skip_all => 'Failed to instantiate the FOEGCL::CSVProvider object')
            unless ref $csv eq 'FOEGCL::CSVProvider';   
        
        $self->_test_init_attr_datafile;
        $self->_test_init_attr_columns;
    }
    
    sub _test_init_attr_datafile {
        my $self = shift;

        # Test that an invalid datafile path dies
        throws_ok {
            FOEGCL::CSVProvider->new(
                datafile => $TEST_INVALID_DATAFILE,
                columns => $self->_csvprovider_columns,
            );            
        } qr/datafile must be a readable file/, 'reject invalid datafile path';
        
        # Instantiation with proper datafile already tested.
    }
    
    sub _test_init_attr_columns {
        my $self = shift;
        
        # Test the columns attribute requiredness
        throws_ok {
            FOEGCL::CSVProvider->new(
                datafile => $self->_csvprovider_datafile,
                skip_header => $self->_csvprovider_skip_header,
                parser_options => $self->_csvprovider_parser_options
            )
        } qr/object without columns/, 'columns is a required attribute';
    }
    
    sub _test_usage {
        my $self = shift;
        
        my $csv = FOEGCL::CSVProvider->new(
            datafile => $self->_csvprovider_datafile,
            columns => $self->_csvprovider_columns,
            skip_header => $self->_csvprovider_skip_header,
            parser_options => $self->_csvprovider_parser_options
        );
        
        can_ok($csv, 'next_record');
        SKIP: {
            skip("because FOEGCL::CSVProvider can't next_record!")
                if ! $csv->can('next_record');
            
            $self->_test_next_record;           
            $self->_test_attr_columns;
            $self->_test_attr_skip_header;
        }
    }
    
    sub _test_next_record {
        my $self = shift;
        
        my $csv = FOEGCL::CSVProvider->new(
            datafile => $self->_csvprovider_datafile,
            columns => $self->_csvprovider_columns,
            skip_header => 0,
            parser_options => $self->_csvprovider_parser_options
        );
        my $record = $csv->next_record;
        eq_or_diff(
            $record,
            {
                a => 'Header A',
                b => 'Header B',
                c => 'Header C',
                d => 'Header D',
                e => 'Header "E"',
                f => '"Header F"',
            },
            'read header row correctly'
        );
        
        my $row_number = 2;
        while ($record = $csv->next_record) {
            eq_or_diff(
                $record,
                {
                    a => 0 + ($row_number - 1),
                    b => 1 + ($row_number - 1),
                    c => 2 + ($row_number - 1),
                    d => 3 + ($row_number - 1),
                    e => 4 + ($row_number - 1),
                    f => 5 + ($row_number - 1),
                },
                "read row $row_number correctly"
            );
            $row_number++;
        }
    }
    
    sub _test_attr_columns {
        my $self = shift;
        
        # Test the columns returns the correct number of columns
        my $csv = FOEGCL::CSVProvider->new(
            datafile => $self->_csvprovider_datafile,
            columns => { a => 1, b => 2, c => 3 },
            skip_header => $self->_csvprovider_skip_header,
            parser_options => $self->_csvprovider_parser_options
        );
        my $record = $csv->next_record;
        is(keys %$record, 3, 'next_record builds requested number of columns');

        # Test that too many columns blows up
        $csv = FOEGCL::CSVProvider->new(
            datafile => $self->_csvprovider_datafile,
            columns => { a => 7 },
            skip_header => $self->_csvprovider_skip_header,
            parser_options => $self->_csvprovider_parser_options
        );
        throws_ok {
            $csv->next_record
        } qr/can't be found/, 'next_record chokes on invalid column number';
    }
    
    sub _test_attr_skip_header {
        my $self = shift;
        
        # Test that skip header works
        my $csv = FOEGCL::CSVProvider->new(
            datafile => $self->_csvprovider_datafile,
            columns => $self->_csvprovider_columns,
            skip_header => 0,
            parser_options => $self->_csvprovider_parser_options
        );
        my $line_count = 0;
        while ($csv->next_record) {
            $line_count++;
        }
        is($line_count, 21, "correctly don't skip header");

        $csv = FOEGCL::CSVProvider->new(
            datafile => $self->_csvprovider_datafile,
            columns => $self->_csvprovider_columns,
            skip_header => 1,
            parser_options => $self->_csvprovider_parser_options
        );
        $line_count = 0;
        while ($csv->next_record) {
            $line_count++;
        }
        is($line_count, 20, "correctly do skip header");
    }

    sub _csvprovider_datafile {
        return $TEST_DATAFILE;
    }

    sub _csvprovider_columns {
        return {
            a => 1,
            b => 2,
            c => 3,
            d => 4,
            e => 5,
            f => 6,
        };
    }

    sub _csvprovider_skip_header {
        return 0;
    }

    sub _csvprovider_parser_options {
        return {
            binary => 1,
            auto_diag => 1,
            diag_verbose => 1,
            eol => qq{\n},
            sep_char => qq{,},
            quote_char => q{"},
            escape_char => q{"},
            always_quote => 1,
            quote_space => 1,
            quote_null => 1,
            quote_binary => 1,
            allow_loose_quotes => 0,
            allow_loose_escapes => 0,
            allow_whitespace => 0,
            blank_is_undef => 0,
            empty_is_undef => 0,
            verbatim => 0,
        };
    }

    1;
}

Test::FOEGCL::CSVProvider->new->run;