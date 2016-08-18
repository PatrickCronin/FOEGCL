package FOEGCLModuleTestTemplate;

use Moo;
use MooX::Types::MooseLike::Base qw( :all );
use Modern::Perl;
use Test::More;
use Test::Differences;
use Scalar::Util qw( openhandle );

has _module_under_test => ( is => 'ro', isa => Str, builder => 1 );

sub _build__module_under_test {
    return '';
}

sub BUILD {
    my $self = shift;
    
    if ($self->_module_under_test eq '') {
        die "Must override the _build__module_under_test method";
    }
}

sub run {
    my $self = shift;
    
    $self->_check_prereqs;
    $self->_test_instantiation;
    $self->_test_attributes;
    $self->_test_methods;
    $self->_test_destruction;
    
    done_testing();
}

# Default implementation: test if we can use the module
sub _check_prereqs {
    my $self = shift;
    
    # Ensure the module can be used
    if (! eval 'use ' . $self->_module_under_test . '; 1' && $@) {
       plan(skip_all => "Can't use " . $self->_module_under_test . "!"); 
    }
}

# Default implementation: test if we can instantiate the object with the
# default args
sub _test_instantiation {
    my $self = shift;
    
    my $obj = new_ok( $self->_module_under_test => [
        $self->_default_object_args
    ] );
    plan(skip_all => "Failed to instantiate the " . $self->_module_under_test . " object")
        unless ref $obj eq $self->_module_under_test;  

    return $obj;
}

# Default implementation: test if we get back the expected values for each of
# the default args
sub _test_attributes {
    my $self = shift;
    
    my %args = $self->_default_object_args;
    pass('No attributes to test.') && return if (keys %args) == 0;
    
    my $obj = $self->_module_under_test->new( %args );
    foreach my $arg (keys %args) {
        eq_or_diff($obj->$arg, $args{$arg}, "$arg attribute set and get");
    }
}

# Default implementation: nothing to test
sub _test_methods {
    pass("no methods to test");
}

# Default implementation: nothing to test
sub _test_destruction {
    pass("no destruction implications to test");
}

# Default implementation: no args for new()
sub _default_object_args {
    return ();
}

sub _default_object_arg {
    my $self = shift;
    my $arg = shift or return;
    
    my %args = $self->_default_object_args;
    die "Arg $arg doesn't exist!" if ! exists $args{$arg};
    
    return $args{$arg};
}

# Read the main::DATA handle and create an href for each row with the labels
# supplied.
sub _read_data_csv {
    my $self = shift;
    my @ordered_field_names = @_;
    
    my @rows = ();
    
    my $data_fh = openhandle(*main::DATA);
    die "DATA filehandle was not opened!" if ! defined $data_fh;
    
    while (my $data = <$data_fh>) {
        chomp $data;

        my @values = split q{,}, $data;
        if (@ordered_field_names != @values) {
            die "Read " . (scalar @values) . " values from the CSV, expected " . (scalar @ordered_field_names);
        }
        
        my %row;
        @row{@ordered_field_names} = @values;

        push @rows, \%row;
    }

    return @rows;
}

# Extract attributes from an object and create a hash with them
sub _extract_attrs {
    my $self = shift;
    my $object = shift;
    my @attrs = @_;
    
    my %hash = ();
    foreach my $attr (@attrs) {
        die ref $object . " can't $attr!" if ! $object->can($attr);
        
        $hash{$attr} = $object->$attr;
    }
    
    return %hash;
}

1;