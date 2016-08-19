#!perl

use Modern::Perl;

{

    package Test::FOEGCL::GOTV::Voter;

    use FindBin;
    use File::Spec::Functions qw( catdir );
    use lib catdir( $FindBin::Bin, 'lib' );
    
    use Moo;
    extends 'FOEGCLModuleTestTemplate';
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Test::Exception;

    has _voters => ( is => 'ro', isa => ArrayRef [HashRef], builder => 1 );

    around _build__module_under_test => sub {
        return 'FOEGCL::GOTV::Voter';
    };

    sub _build__voters {
        my $self = shift;

        my @row_hrefs = $self->_read_data_csv(
            qw(
              voter_registration_id
              first_name
              last_name
              street_address
              zip
              )
        );

        return \@row_hrefs;
    }

    around _test_methods => sub {
        my $orig = shift;
        my $self = shift;

        subtest $self->_module_under_test . '->stringify' => sub {
            $self->_test_method_stringify;
          }
    };

    around _default_object_args => sub {
        my $orig = shift;
        my $self = shift;

        return %{ $self->_voters->[0] };
    };

    sub _test_method_stringify {
        my $self = shift;

        my $voter =
          $self->_module_under_test->new( $self->_default_object_args );
        my $stringified = can_ok( $voter, 'stringify' );
        plan( skip_all => $self->_module_under_test . q{ can't stringify!} )
          if !$voter->can('stringify');
        ok( length($stringified) > 0, 'stringifies ok' );

        return;
    }

    1;
}

Test::FOEGCL::GOTV::Voter->new->run;

# voter_registration_id, first_name, last_name, street_address, zip
__DATA__
30015588441,Kimya,Dawson,9 Charlotte Pl,28183
1978022514,Phyllis,Stoffels,42 Main St.',44442
