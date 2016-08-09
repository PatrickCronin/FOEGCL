package FOEGCL::ItemHash;

use Moo;
use MooX::Types::MooseLike::Base qw( :all );
use Carp qw( croak );
use List::Util qw( any );

our $VERSION = '0.01';

has hash_keys => ( is => 'ro', isa => ArrayRef[ Str ], builder => 1 );
has case_sensitive => ( is => 'ro', isa => Int, default => 0 );
has _item_hash => ( is => 'ro', isa => HashRef, default => sub { {} } );

sub _build_hash_keys {
    return [];
}

sub BUILD {
    my $self = shift;
    
    if (scalar keys $self->hash_keys == 0) {
        croak "hash_keys must contain at least one key";;
    }
}

sub add_item {
    my $self = shift;
    my $item = shift;

    my $hash_node = $self->_vivify_hash_node($self->_hash_keys($item));
    push @$hash_node, $item;
}

sub retrieve_items_like_item {
    my $self = shift;
    my $item = shift;
    
    return $self->_hash_node(
        $self->_hash_keys($item)
    );
}

sub has_item_like_item_matching_str {
    my $self = shift;
    my $item = shift;
    my $field_to_match = shift;
    
    my $hashed_items = $self->retrieve_items_like_item($item);
    
    if ($self->case_sensitive) {
        return any {
            $item->$field_to_match eq $_->$field_to_match
        } @$hashed_items;
    }
    else {
        return any {
            lc $item->$field_to_match eq lc $_->$field_to_match
        } @$hashed_items;    
    }
}

sub _hash_keys {
    my $self = shift;
    my $item = shift;
    
    my @hash_keys = ();
    foreach my $hash_key (@{ $self->hash_keys }) {
        push @hash_keys, $item->$hash_key;
    }
    
    if (! $self->case_sensitive) {
        @hash_keys = map { lc $_ } @hash_keys;
    }
    
    return @hash_keys;
}

sub _vivify_hash_node {
    my $self = shift;
    my @hash_keys = @_;

    my $hash_node = $self->_item_hash;
    while (my $hash_key = shift @hash_keys) {
        if (! exists $hash_node->{ $hash_key }) {
            $hash_node->{ $hash_key } = (@hash_keys > 0 ? {} : []);
        }
        $hash_node = $hash_node->{ $hash_key };
    }

    return $hash_node;
}

sub _hash_node {
    my $self = shift;
    my @hash_keys = @_;
    
    my $hash_node = $self->_item_hash;
    foreach my $hash_key (@hash_keys) {
        return if ! exists $hash_node->{ $hash_key };
        $hash_node = $hash_node->{ $hash_key };
    }
    
    return $hash_node;
}

1;

__END__

=head1 NAME

FOEGCL::ItemHash - The great new FOEGCL::ItemHash!

=head1 VERSION

Version 0.01


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use FOEGCL::ItemHash;

    my $foo = FOEGCL::ItemHash->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=head2 function2

=head1 AUTHOR

Patrick Cronin, C<< <patrick at cronin-tech.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-foegcl at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FOEGCL>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FOEGCL::ItemHash


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


=head1 ACKNOWLEDGEMENTS


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

