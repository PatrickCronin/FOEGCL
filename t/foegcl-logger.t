use Modern::Perl;

{
    package Test::FOEGCL::Logger;
    BEGIN { chdir 't' if -d 't' }
    use lib '../lib';
    use Moo;
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Test::Differences;
    use English qw( -no_match_vars );
    use Readonly;
    
    Readonly my $LOGFILE_NAME => 'testlog.out';

    has _logfile => ( is => 'ro', isa => Str, builder => 1 );    
    has _logger => (
        is => 'rw',
        isa => InstanceOf[ 'FOEGCL::Logger' ],
        clearer => 1,
    );
    
    sub _build__logfile {
        return $LOGFILE_NAME;
    }
    
    sub DEMOLISH {
        my $self = shift;
        
        if (-e $self->_logfile) {
           unlink $self->_logfile
               or die "Failed to delete test logfile at " . $self->_logfile . ": $OS_ERROR";
        }
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
    
        # Ensure the FOEGCL::Logger module can be used
        if (! use_ok('FOEGCL::Logger')) {
            plan(skip_all => 'Failed to use the FOEGCL::Logger module');
        }
        
        # Delete $self->_logfile if it exists
        if (-e $self->_logfile) {
            plan(skip_all => $self->_logfile . " exists, isn't a file")
                if !-f $self->_logfile;
            plan(skip_all => $self->_logfile . " exists, current user can't delete")
                if !-w $self->_logfile;
            plan(skip_all => "could not delete " . $self->_logfile . " for testing: $OS_ERROR")
                unless unlink $self->_logfile;
        }
    }
    
    sub _test_instantiation {
        my $self = shift;
        
        my $logger_object = new_ok( 'FOEGCL::Logger' => [ 'logfile', $self->_logfile ] );
        plan(skip_all => 'Failed to instantiate the FOEGCL::Logger object')
            unless ref $logger_object eq 'FOEGCL::Logger';
            
        $self->_logger($logger_object);
    }
    
    sub _test_usage {
        my $self = shift;
        
        $self->_test_log;
    }
    
    sub _test_log {
        my $self = shift;

        can_ok($self->_logger, 'log');

        SKIP: {
            skip("because FOEGCL::Logger can't log!", 1) if
                ! $self->_logger->can('log');

            my @events = (
                'Event 1: Random string A.',
                'Event 2: Random string B.',
                'Event 3: Random string C.',
                'Event 4: Random string D.',
                'Event 5: Random string E.',
            );
        
            # logfile hasn't been used - should not exist
            is(-e $self->_logfile, undef, "logfile not created before use");
        
            # Add an item to the log, and then the logfile should exist
            ok($self->_logger->log($events[0]), "calling log");
            is(-e $self->_logfile, 1, "logfile created on first use");
        
            # Add remaining items to the log
            foreach my $event (@events[1..$#events]) {
                ok($self->_logger->log($event), "calling log");
            }
        
            $self->_clear_logger;
            my $logfile_contents = $self->_read_logfile_contents;
            eq_or_diff(
                $logfile_contents,
                (join qq{\n}, @events) . "\n",
                'logfile has correct contents'
            );
        }
    }
    
    sub _read_logfile_contents {
        my $self = shift;
        
        open my $fh, '<:encoding(utf8)', $self->_logfile
            or die "Failed to open the logfile to verify its contents: $OS_ERROR";
        local $/ = undef;
        my $logfile_contents = <$fh>;
        close $fh;
        
        return $logfile_contents;
    }
    
    1;
}

Test::FOEGCL::Logger->new->run;