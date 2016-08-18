#!perl

use Modern::Perl;

{

    package Test::FOEGCL::Logger;

    BEGIN { chdir 't' if -d 't' }
    use lib '../lib', 'lib';
    use Moo;
    extends 'FOEGCLModuleTestTemplate';
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Test::Differences;
    use English qw( -no_match_vars );
    use Carp qw( croak );
    use Readonly;

    Readonly my $LOGFILE_NAME => 'testlog.out';

    has _logfile => ( is => 'ro', isa => Str, builder => 1 );
    has _logger => (
        is      => 'rw',
        isa     => InstanceOf ['FOEGCL::Logger'],
        clearer => 1,
    );

    around _build__module_under_test => sub {
        return 'FOEGCL::Logger';
    };

    sub _build__logfile {
        return $LOGFILE_NAME;
    }

    sub DEMOLISH {
        my $self = shift;

        if ( -e $self->_logfile ) {
            unlink $self->_logfile
              or croak q{Failed to delete test logfile at }
              . $self->_logfile
              . ": $OS_ERROR";
        }

        return;
    }

    after _check_prereqs => sub {
        my $self = shift;

        # Delete $self->_logfile if it exists
        if ( -e $self->_logfile ) {
            plan( skip_all => $self->_logfile . q{ exists, isn't a file} )
              if !-f $self->_logfile;
            plan( skip_all => $self->_logfile
                  . q{ exists, current user can't delete} )
              if !-w $self->_logfile;
            plan(   skip_all => q{could not delete }
                  . $self->_logfile
                  . " for testing: $OS_ERROR" )
              unless unlink $self->_logfile;
        }
    };

    around _test_instantiation => sub {
        my $orig = shift;
        my $self = shift;

        $self->_logger( $self->$orig );
    };

    around _test_methods => sub {
        my $orig = shift;
        my $self = shift;

        subtest $self->_module_under_test . '->add' => sub {
            $self->_test_method_add;
        };
    };

    around _default_object_args => sub {
        my $orig = shift;
        my $self = shift;

        return ( logfile => $self->_logfile );
    };

    sub _test_method_add {
        my $self = shift;

        can_ok( $self->_logger, 'add' );
        plan( skip_all => $self->_module_under_test . q{ can't add!} )
          if !$self->_logger->can('add');

        my @events = (
            'Event 1: Random string A.',
            'Event 2: Random string B.',
            'Event 3: Random string C.',
            'Event 4: Random string D.',
            'Event 5: Random string E.',
        );

        # Add an item to the log, and then the logfile should exist
        ok( $self->_logger->add( $events[0] ), "logging $events[0]" );

        # Add remaining items to the log
        foreach my $event ( @events[ 1 .. $#events ] ) {
            ok( $self->_logger->add($event), "logging $event" );
        }

        # Close log (to avoid buffering issues), and ensure contents
        $self->_clear_logger;
        my $logfile_contents = $self->_read_logfile_contents;
        eq_or_diff(
            $logfile_contents,
            ( join qq{\n}, @events ) . "\n",
            'logfile has correct contents'
        );

        return;
    }

    sub _read_logfile_contents {
        my $self = shift;

        open my $fh, '<:encoding(utf8)', $self->_logfile
          or croak
          "Failed to open the logfile to verify its contents: $OS_ERROR";
        my $logfile_contents =
          do { local $INPUT_RECORD_SEPARATOR = undef; <$fh> };
        close $fh or croak "Failed to close filehandle: $OS_ERROR";

        return $logfile_contents;
    }

    1;
}

Test::FOEGCL::Logger->new->run;
