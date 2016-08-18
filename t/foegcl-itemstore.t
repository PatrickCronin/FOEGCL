use Modern::Perl;

{
    package Test::FOEGCL::ItemStore;
    
    BEGIN { chdir 't' if -d 't' }
    use lib '../lib', 'lib';
    use Moo;
    extends 'FOEGCLModuleTestTemplate';
    use MooX::Types::MooseLike::Base qw( :all );
    use Test::More;
    use Test::Differences;
    use Test::Exception;
    use Test::Deep;

    has _cars => ( is => 'ro', isa => ArrayRef[ InstanceOf[ 'Car' ] ], builder => 1 );
    has _item_store => ( is => 'rw', isa => InstanceOf[ 'FOEGCL::ItemStore' ] );
    
    around _build__module_under_test => sub {
        return 'FOEGCL::ItemStore';
    };
    
    sub _build__cars {
        my $self = shift;
        
        return [
            map { bless $_, 'Car' } ($self->_read_data_csv( $self->_car_attrs ))
        ];
    }

    around _test_instantiation => sub {
        my $orig = shift;
        my $self = shift;
        
        $self->_item_store( $self->$orig );
    };
    
    around _test_methods => sub {
        my $orig = shift;
        my $self = shift;
        
        subtest $self->_module_under_test . '->add_item' => sub {
            $self->_test_method_add_item
        };
        
        subtest $self->_module_under_test . '->retrieve_items_like_item' => sub {
            $self->_test_method_retrieve_items_like_item
        };

        subtest $self->_module_under_test . '->has_item_like_item_matching_str' => sub {
            $self->_test_method_has_item_like_item_matching_str
        };        
    };
    
    around _default_object_args => sub {
        return (
            index_keys => [ qw( year make model ) ],
            case_sensitive => 0,
        );
    };
    
    sub _test_method_add_item {
        my $self = shift;
        
        plan(skip_all => $self->_module_under_test . " can't add_item!") if
            ! $self->_item_store->can('add_item');
        
        foreach my $car (@{ $self->_cars }) {
            lives_ok { $self->_item_store->add_item($car) } 'added car';
                        
            # Test storage hierarchy
            ok(
                ref $self->_item_store->_item_store eq 'HASH'
                && exists $self->_item_store->_item_store->{ $car->year }
                && ref $self->_item_store->_item_store->{ $car->year } eq 'HASH'
                && exists $self->_item_store->_item_store->{ $car->year }->{ lc $car->make }
                && ref $self->_item_store->_item_store->{ $car->year }->{ lc $car->make } eq 'HASH'
                && exists $self->_item_store->_item_store->{ $car->year }->{ lc $car->make }->{ lc $car->model }
                && ref $self->_item_store->_item_store->{ $car->year }->{ lc $car->make }->{ lc $car->model } eq 'ARRAY',
                'storage allocated correctly'
            );
            
            # Test that actual item can be found
            cmp_deeply(
                $self->_item_store->_item_store->{ $car->year }->{ lc $car->make }->{ lc $car->model },
                superbagof($car),
                'car found in storage'
            );
        }
    }
    
    sub _test_method_retrieve_items_like_item {
        my $self = shift;
        
        my $car = Car->new(
            year => 2015,
            make => 'Subaru',
            model => 'Outback',
        );
        
        my $like_cars = $self->_item_store->retrieve_items_like_item( $car );
        eq_or_diff(
            $like_cars,
            $self->_item_store->_item_store->{ $car->year }->{ lc $car->make }->{ lc $car->model },
            'correctly retrieve items like item'
        );
    }
    
    sub _test_method_has_item_like_item_matching_str {
        my $self = shift;
        
        my $yes_car = Car->new(
            year => 2015,
            make => 'Subaru',
            model => 'Outback',
            trim => '3.6R Limited',
        );
        ok(
            $self->_item_store->has_item_like_item_matching_str($yes_car, 'trim'),
            'find matching item'
        );
        
        my $no_car = Car->new(
            year => 2015,
            make => 'Subaru',
            model => 'Outback',
            trim => '3.0T Limited',        
        );
        ok(
            ! $self->_item_store->has_item_like_item_matching_str($no_car, 'trim'),
            'identify when no items match'
        );
            
    }
    
    sub _car_attrs {
        return qw( year make model trim );
    }
    
    package Car;
    use Moo;
    use MooX::Types::MooseLike::Base qw( :all );
    
    has year => ( is => 'ro', isa => Str, requried => 1);
    has make => ( is => 'ro', isa => Str, requried => 1);
    has model => ( is => 'ro', isa => Str, requried => 1);
    has trim => ( is => 'ro', isa => Str, requried => 1);
}

Test::FOEGCL::ItemStore->new->run;

# Year, Make, Model, Trim
__DATA__
2014,Honda,Accord,LX
2015,Honda,Accord,LX
2016,Honda,Accord,LX
2014,Honda,Accord,EX
2015,Honda,Accord,EX
2016,Honda,Accord,EX
2014,Honda,Accord,EX-L
2015,Honda,Accord,EX-L
2016,Honda,Accord,EX-L
2014,Toyota,Camry,L
2015,Toyota,Camry,L
2016,Toyota,Camry,L
2014,Toyota,Camry,LE
2015,Toyota,Camry,LE
2016,Toyota,Camry,LE
2014,Toyota,Camry,SE
2015,Toyota,Camry,SE
2016,Toyota,Camry,SE
2014,Toyota,Camry,XLE
2015,Toyota,Camry,XLE
2016,Toyota,Camry,XLE
2014,Subaru,Outback,2.5i
2015,Subaru,Outback,2.5i
2016,Subaru,Outback,2.5i
2014,Subaru,Outback,2.5i Premium
2015,Subaru,Outback,2.5i Premium
2016,Subaru,Outback,2.5i Premium
2014,Subaru,Outback,2.5i Limited
2015,Subaru,Outback,2.5i Limited
2016,Subaru,Outback,2.5i Limited
2014,Subaru,Outback,2.5i Touring
2015,Subaru,Outback,2.5i Touring
2016,Subaru,Outback,2.5i Touring
2014,Subaru,Outback,3.6R Limited
2015,Subaru,Outback,3.6R Limited
2016,Subaru,Outback,3.6R Limited
2014,Subaru,Outback,3.6R Touring
2015,Subaru,Outback,3.6R Touring
2016,Subaru,Outback,3.6R Touring