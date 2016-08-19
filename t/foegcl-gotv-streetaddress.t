#!perl

use Modern::Perl;

{

    package Test::FOEGCL::GOTV::StreetAddress;

    use FindBin;
    use File::Spec::Functions qw( catdir );
    use lib catdir( $FindBin::Bin, 'lib' );
    
    use Moo;
    extends 'FOEGCLModuleTestTemplate';
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Test::Differences;

    has _sa =>
      ( is => 'rw', isa => InstanceOf ['FOEGCL::GOTV::StreetAddress'] );

    around _build__module_under_test => sub {
        return 'FOEGCL::GOTV::StreetAddress';
    };

    around _test_instantiation => sub {
        my $orig = shift;
        my $self = shift;

        $self->_sa( $self->$orig );
    };

    around _test_methods => sub {
        my $orig = shift;
        my $self = shift;

        subtest $self->_module_under_test . '->clean' => sub {
            $self->_test_method_clean;
        };

        subtest $self->_module_under_test . '->standardize' => sub {
            $self->_test_method_standardize;
        };
    };

    sub _test_method_clean {
        my $self = shift;

        my %qa = (
            '   418     Broadway     '             => '418 Broadway',
            "22\t\fLindberg\t\t\r     \n\f Street" => '22 Lindberg Street',
        );

        foreach my $question ( keys %qa ) {
            eq_or_diff( $self->_sa->clean($question),
                $qa{$question}, 'cleans ' . $question );
        }

        return;
    }

    sub _test_method_standardize {
        my $self = shift;

        my %qa = (
            '418 Broadway'       => '418 Broadway',
            '22 Lindberg Street' => '22 Lindberg St',
            '281A 32nd St.'      => '281A 32nd St',
        );

        foreach my $question ( keys %qa ) {
            eq_or_diff(
                $self->_sa->standardize($question),
                uc $qa{$question},
                'standardizes ' . $question
            );
        }

        return;
    }

    1;
}

Test::FOEGCL::GOTV::StreetAddress->new->run;
