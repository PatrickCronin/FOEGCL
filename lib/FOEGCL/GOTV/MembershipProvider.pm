package FOEGCL::GOTV::MembershipProvider;

use Moo;
extends 'FOEGCL::CSVProvider';
use FOEGCL::GOTV::Membership;
use FOEGCL::GOTV::Friend;

our $VERSION = '0.01';

around _build_columns => sub {
    return {
        'friend_id' => 1,
        'first_name' => 2,
        'last_name' => 3,
        'spouse_first_name' => 4,
        'spouse_last_name' => 5,
        'street_address' => 6,
        'zip' => 8,
        'registered_voter' => 7,
    };
};

around _build_skip_header => sub {
    return 1;
};

around next_record => sub {
    my $orig = shift;
    my $self = shift;
    
    my $record = $self->$orig();
    return if ! defined $record;
    
    my @friends = ();
    push @friends, FOEGCL::GOTV::Friend->new(
        friend_id => $record->{'friend_id'},
        first_name => $record->{'first_name'},
        last_name => $record->{'last_name'},
        street_address => $self->_clean_street_address(
            $record->{'street_address'}
        ),
        zip => $record->{'zip'},
        registered_voter => ($record->{'registered_voter'} eq 'TRUE' ? 1 : 0),
    );
    
    if (defined $record->{'spouse_first_name'}
        && defined $record->{'spouse_last_name'}) {
        push @friends, FOEGCL::GOTV::Friend->new(
            friend_id => $record->{'friend_id'},
            first_name => $record->{'spouse_first_name'},
            last_name => $record->{'spouse_last_name'},
            street_address => $self->_clean_street_address(
                $record->{'street_address'}
            ),
            zip => $record->{'zip'},
            registered_voter => ($record->{'registered_voter'} eq 'TRUE' ? 1 : 0),
        );        
    }
    
    return FOEGCL::GOTV::Membership->new(
        membership_id => $friends[0]->friend_id,
        friends => \@friends
    );
};

1;

=head1 NAME

FOEGCL::GOTV::MembershipProvider - The great new FOEGCL::GOTV::MembershipProvider!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use FOEGCL::GOTV::MembershipProvider;

    my $foo = FOEGCL::GOTV::MembershipProvider->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Patrick Cronin, C<< <patrick at cronin-tech.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-foegcl at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FOEGCL>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FOEGCL::GOTV::MembershipProvider


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
