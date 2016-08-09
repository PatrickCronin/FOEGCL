package FOEGCL::GOTV::Friend;

use Moo;
use MooX::Types::MooseLike::Base qw( :all );
use overload '""' => 'stringify';

our $VERSION = '0.01';

has friend_id => ( is => 'ro', isa => Str, required => 1);
has first_name => ( is => 'ro', isa => Str, required => 1 );
has last_name => ( is => 'ro', isa => Str, required => 1 );
has street_address => ( is => 'ro', isa => Str, required => 1 );
has zip => ( is => 'ro', isa => Str, required => 1 );
has registered_voter => ( is => 'ro', isa => Int, required => 1 );

sub stringify {
    my $self = shift;
    
    return $self->first_name . ' ' . $self->last_name .  "\n" .
        $self->street_address . "\n" .
        $self->zip;
}

1; # End of FOEGCL::GOTV::Friend

=head1 NAME

FOEGCL::GOTV::Friend - The great new FOEGCL::GOTV::Friend!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use FOEGCL::GOTV::Friend;

    my $foo = FOEGCL::GOTV::Friend->new();
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

    perldoc FOEGCL::GOTV::Friend


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
