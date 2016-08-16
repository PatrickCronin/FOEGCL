package FOEGCLModuleTestTemplate;

use Modern::Perl;
use Test::More;
use Moo;
use MooX::Types::MooseLike::Base qw( :all );

has _module_name => ( is => 'ro', isa => Str, builder => 1 );

sub _build__module_name {
    return '';
}

sub BUILD {
    my $self = shift;
    
    if ($self->_module_name eq '') {
        die "Must override the _build__module_name method";
    }
}

sub run {
    my $self = shift;
    
    $self->_check_prereqs;
    $self->_test_instantiation;
    $self->_test_usage;
    $self->_test_destruction;
    
    done_testing();
}

sub _check_prereqs {
    my $self = shift;
    
    # Ensure the module can be used
    if (! eval 'use ' . $self->_module_name . '; 1' || $@) {
       plan(skip_all => "Can't use " . $self->_module_name . "!"); 
    }
}

sub _test_instantiation {
    return;
}

sub _test_usage {
    return;
}

sub _test_destruction {
    return;
}

1;