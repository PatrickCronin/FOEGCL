package FOEGCL::ItemStore;

use Moo;
use MooX::Types::MooseLike::Base qw( :all );
use List::Util qw( any );

our $VERSION = '0.01';

has index_keys => ( is => 'ro', isa => ArrayRef [Str], builder => 1 );
has case_sensitive => ( is => 'ro', isa => Bool, default => 0 );
has _item_store => ( is => 'ro', isa => HashRef, default => sub { {} } );

# Here to allow subclasses provide specific implementation
sub _build_index_keys {
    return [];
}

# Verify we have at least 1 index key
sub BUILD {
    my $self = shift;

    if ( scalar keys $self->index_keys == 0 ) {
        FOEGCL::Error->throw('index_keys must contain at least one key');
    }

    return;
}

# Add an item to the store
sub add_item {
    my $self = shift;
    my $item = shift;

    my $store_node =
      $self->_vivify_store_node_at_index( $self->_index_keys($item) );
    push @{$store_node}, $item;

    return $self;
}

# Return all stored items with the same index keys as the provided item
sub retrieve_items_like_item {
    my $self = shift;
    my $item = shift;

    return $self->_store_node_at_index( $self->_index_keys($item) );
}

# Return all stored items with the same index keys as the provided item AND
# that match (string-like) on the specified field as well.
sub has_item_like_item_matching_str {
    my $self           = shift;
    my $item           = shift;
    my $field_to_match = shift;

    my $like_items = $self->retrieve_items_like_item($item);

    if ( $self->case_sensitive ) {
        return any {
            $item->$field_to_match eq $_->$field_to_match
        }
        @{$like_items};
    }

    return any {
        CORE::fc $item->$field_to_match eq CORE::fc $_->$field_to_match
    }
    @{$like_items};
}

# Collect an item's index keys
sub _index_keys {
    my $self = shift;
    my $item = shift;

    my @index_keys = map { $item->$_ } @{ $self->index_keys };
    if ( !$self->case_sensitive ) {
        @index_keys = map { CORE::fc } @index_keys;
    }

    return @index_keys;
}

# Create a node in the item store at a given set of index keys
sub _vivify_store_node_at_index {
    my ( $self, @index_keys ) = @_;

    my $store_node = $self->_item_store;
    while ( my $index_key = shift @index_keys ) {
        if ( !exists $store_node->{$index_key} ) {
            $store_node->{$index_key} = ( @index_keys > 0 ? {} : [] );
        }
        $store_node = $store_node->{$index_key};
    }

    return $store_node;
}

# Get the ArrayRef of items at a particular index in the item store.
sub _store_node_at_index {
    my ( $self, @index_keys ) = @_;

    my $store_node = $self->_item_store;
    foreach my $index_key (@index_keys) {
        return if !exists $store_node->{$index_key};
        $store_node = $store_node->{$index_key};
    }

    return $store_node;
}

1;

__END__

=head1 NAME

FOEGCL::ItemStore - Indexed item storage.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This module stores items in buckets according to selected attributes. For
example, if you were storing people, you could create the ItemStore using
first_name and last_name as keys, and by doing so, each person with the same
first and last name would be stored together. Then, retrieving all people with
a specific first and last name is as easy as retriving the contents of a
particular bucket.

    use FOEGCL::ItemStore;

    my $storage = FOEGCL::ItemStore->new(
        item_keys => [qw( last_name first_name )],
        case_sensitive => 0,
    );
    
    # For the purpose of this synopsis, assume that a Person object has
    # the first_name, last_name and middle_initial attributes.
    
    $storage->add_item($person1);
    $storage->add_item($person2);
    $storage->add_item($person3);
    
    if ($storage->retrieve_items_like_item($person4)) {
        say "Found item like $person4";
    }
   
    if ($storage->has_item_like_item_matching_str($person5, 'middle_initial') {
        say "There's already a person with the same full name!";
    }

=head1 ATTRIBUTES

=head2 index_keys

  An ArrayRef of the store's keys. These keys must be defined attributes on the
  items that will be added to the store. Order is relevant: items will be
  indexed for storage in the same order that the Store's keys were specified.
  Required. Include with call to new(), read-only thereafter.

=head2 case_sensitive

  Specify whether the items' index values should be treated as case
  sensitive or not. Defaults to no. Include with call to new(), read-only
  thereafter.

=head1 METHODS

=head2 add_item

  Add an item to the store.
  
    $store->add_item($item);

=head2 retrieve_items_like_item

  Retrieve all items that have the same index values as the provided item.
  
    $store->retrieve_items_like_item($item);

=head2 has_item_like_item_matching_str

  Determine whether or not an item with the same index values as the provide
  item has already been stored that ALSO matches (string-like) an additional
  field with the provided item.
  
    $store->has_item_like_item_matching_str($item);

=head1 AUTHOR

Patrick Cronin, C<< <patrick at cronin-tech.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-foegcl at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FOEGCL>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FOEGCL::ItemStore

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=FOEGCL>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/FOEGCL>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/FOEGCL>

=item * Search CPAN

L<http://search.cpan.org/dist/FOEGCL/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Patrick Cronin.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.

=cut
