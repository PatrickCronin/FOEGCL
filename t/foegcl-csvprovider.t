#!perl

use Modern::Perl;

{

    package Test::FOEGCL::CSVProvider;

    use FindBin;
    use File::Spec::Functions qw( catdir catfile );
    use lib catdir( $FindBin::Bin, 'lib' );
    
    use Moo;
    extends 'FOEGCLModuleTestTemplate';
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Test::Differences;
    use Test::Exception;
    use Readonly;

    has _test_datafile => ( is => 'ro', isa => Str, builder => 1 );
    has _test_invalid_datafile => ( is => 'ro', isa => Str, builder => 1 );

    Readonly my $TEST_DATAFILE => 'csvprovider-test-datafile.csv';
    Readonly my $TEST_INVALID_DATAFILE =>
      'csvprovider-invalid-test-datafile.csv';

    sub _build__test_datafile {
        my $self = shift;
        
        return catfile( $FindBin::Bin, $TEST_DATAFILE );
    }
    
    sub _build__test_invalid_datafile {
        my $self = shift;
        
        return catfile( $FindBin::Bin, $TEST_INVALID_DATAFILE );
    }

    around _build__module_under_test => sub {
        return 'FOEGCL::CSVProvider';
    };

    after _check_prereqs => sub {
        my $self = shift;

        # Ensure the testing datafile exists
        if ( !-e $self->_test_datafile ) {
            plan( skip_all => q{The testing datafile can't be found at }
                  . $self->_test_datafile
            );
        }

        # Ensure the invalid testing datafile doesn't exist
        if ( -e $self->_test_invalid_datafile
            && !unlink $self->_test_invalid_datafile
        ) {
            plan( skip_all =>
q{The invalid testing datafile shouldn't exist, and can't be deleted at }
                  . $self->_test_invalid_datafile
            );
        }
    };

    around _test_attributes => sub {
        my $orig = shift;
        my $self = shift;

        $self->$orig;

        $self->_test_attr_datafile;
        $self->_test_attr_columns;
        $self->_test_attr_skip_header;
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
        
        return (
            datafile    => $self->_test_datafile,
            columns     => { a => 1, b => 2, c => 3, d => 4, e => 5, f => 6, },
            skip_header => 0,
            parser_options => {
                binary              => 1,
                auto_diag           => 1,
                diag_verbose        => 1,
                eol                 => qq{\n},
                sep_char            => q{,},
                quote_char          => q{"},
                escape_char         => q{"},
                always_quote        => 1,
                quote_space         => 1,
                quote_null          => 1,
                quote_binary        => 1,
                allow_loose_quotes  => 0,
                allow_loose_escapes => 0,
                allow_whitespace    => 0,
                blank_is_undef      => 0,
                empty_is_undef      => 0,
                verbatim            => 0,
            }
        );
    };

    sub _test_attr_datafile {
        my $self = shift;

        # Test that an invalid datafile path dies
        ## no critic (RequireDotMatchAnything, RequireLineBoundaryMatching)
        throws_ok {
            $self->_module_under_test->new(
                datafile => $self->_test_invalid_datafile,
                columns  => $self->_default_object_arg('columns')
            );
        }
        qr/datafile must be a readable file/, 'reject invalid datafile path';
        ## use critic

        # Instantiation with proper datafile already tested.

        return;
    }

    sub _test_attr_columns {
        my $self = shift;

        my %args = $self->_default_object_args;

        # Test the columns attribute requiredness
        my %default_args_no_columns = %args;
        delete $default_args_no_columns{'columns'};
        ## no critic (RequireDotMatchAnything, RequireLineBoundaryMatching)
        throws_ok {
            $self->_module_under_test->new(%default_args_no_columns)
        }
        qr/object without columns/, 'columns is a required attribute';
        ## use critic

        # Test instantiation with few or out-of-range columns
      SKIP: {
            my %default_args_custom_columns = %args;
            $default_args_custom_columns{columns} = { a => 1, b => 2, c => 3 };

            my $csv =
              $self->_module_under_test->new(%default_args_custom_columns);
            skip('because next_record is required for testing columns')
              if !$csv->can('next_record');

            # Test that a limited number of columns works
            my $row_record = $csv->next_record;
            is(
                keys %{$row_record},
                3,    ## no critic (ProhibitMagicNumbers)
                'next_record builds requested number of columns'
            );

            # Test that too many columns blows up
            $default_args_custom_columns{columns} = { a => 7 };
            $csv = $self->_module_under_test->new(%default_args_custom_columns);
            ## no critic (RequireDotMatchAnything, RequireLineBoundaryMatching, RequireExtendedFormatting)
            throws_ok {
                $csv->next_record
            }
            qr/can't be found/, 'next_record chokes on invalid column number';
            ## use critic
        }

        return;
    }

    sub _test_attr_skip_header {
        my $self = shift;

        my %args = $self->_default_object_args;

        # Test that skip header works
      SKIP: {
            my %default_args_custom_skip_header = %args;
            $default_args_custom_skip_header{skip_header} = 0;
            my $csv =
              $self->_module_under_test->new(%default_args_custom_skip_header);

            skip('because next_record is required for testing skip_header')
              if !$csv->can('next_record');

            my $line_count = 0;
            while ( $csv->next_record ) {
                $line_count++;
            }
            is(
                $line_count,
                21,    ## no critic (ProhibitMagicNumbers)
                q{correctly don't skip header}
            );

            $default_args_custom_skip_header{skip_header} = 1;
            $csv =
              $self->_module_under_test->new(%default_args_custom_skip_header);
            $line_count = 0;
            while ( $csv->next_record ) {
                $line_count++;
            }
            is(
                $line_count,
                20,    ## no critic (ProhibitMagicNumbers)
                'correctly do skip header'
            );
        }

        return;
    }

    sub _test_method_next_record {
        my $self = shift;

        my $csv = $self->_module_under_test->new( $self->_default_object_args );
        can_ok( $csv, 'next_record' );
        plan( skip_all => $self->_module_under_test . q{ can't next_record!} )
          if !$csv->can('next_record');

        my $row_record = $csv->next_record;
        eq_or_diff(
            $row_record,
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
        while ( $row_record = $csv->next_record ) {
            eq_or_diff(
                $row_record,
                {
                    a => 0 + ( $row_number - 1 ),
                    b => 1 + ( $row_number - 1 ),
                    c => 2 + ( $row_number - 1 ),
                    d => 3 + ( $row_number - 1 ),
                    e => 4 + ( $row_number - 1 ),
                    f => 5 + ( $row_number - 1 ),
                },
                "read row $row_number correctly"
            );
            $row_number++;
        }

        return;
    }

    1;
}

Test::FOEGCL::CSVProvider->new->run;
