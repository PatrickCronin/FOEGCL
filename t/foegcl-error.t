#!perl

use Modern::Perl;

{

    package Test::FOEGCL::Error;
    BEGIN { chdir 't' if -d 't' }
    use lib '../lib', 'lib';

    use Moo;
    extends 'FOEGCLModuleTestTemplate';
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Test::Exception;
    use Readonly;

    Readonly my $ERROR_MESSAGE => 'The engine room exploded!';

    has _error => ( is => 'rw', isa => InstanceOf ['FOEGCL::Error'] );

    around _build__module_under_test => sub {
        return 'FOEGCL::Error';
    };

    # Store the instantiated object for later use
    around _test_instantiation => sub {
        my $orig = shift;
        my $self = shift;

        $self->_error( $self->$orig );
    };

    # Verify the stack_track attribute has been included
    after _test_attributes => sub {
        my $self = shift;

        can_ok( $self->_error, 'stack_trace' );
        if ( $self->_error->can('stack_trace') ) {
            ok( length( $self->_error->stack_trace ),
                q{stack trace isn't empty} );
        }
    };

    around _test_methods => sub {
        my $orig = shift;
        my $self = shift;

        subtest $self->_module_under_test . '->throw' => sub {
            $self->_test_method_throw;
        };
    };

    around _default_object_args => sub {
        return ( message => $ERROR_MESSAGE );
    };

    sub _test_method_throw {
        my $self = shift;

        can_ok( $self->_module_under_test, 'throw' );
        plan( skip_all => $self->_module_under_test . q{ can't throw!} )
          if !$self->_error->can('throw');

        throws_ok {
            $self->_module_under_test->throw($ERROR_MESSAGE)
        }
        'FOEGCL::Error', 'throws the correct class of error object';

        ## no critic (RequireDotMatchAnything, RequireLineBoundaryMatching, RequireExtendedFormatting)
        throws_ok {
            $self->_module_under_test->throw($ERROR_MESSAGE);
        }
        qr/$ERROR_MESSAGE/, 'error object stringifies ok';
        ## use critic

        return;
    }

    1;
}

Test::FOEGCL::Error->new->run;
