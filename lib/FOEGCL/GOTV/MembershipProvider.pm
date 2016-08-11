package FOEGCL::GOTV::MembershipProvider;

use Moo;
extends 'FOEGCL::CSVProvider';
use FOEGCL::GOTV::Membership;
use FOEGCL::GOTV::Friend;
use FOEGCL::GOTV::StreetAddress;
use Readonly;

Readonly my $SPOUSE_RECORD => 1;

our $VERSION = '0.01';

# Specify parser options for a CSV exported from MS Access on Windows.
around _build_parser_options => sub {
    return {
        binary => 1,
        auto_diag => 1,
        diag_verbose => 1,
        eol => qq{\r\n},
        sep_char => qq{,},
        quote_char => q{"},
        escape_char => q{"},
        always_quote => 1,
        quote_space => 1,
        quote_null => 1,
        quote_binary => 1,
        allow_loose_quotes => 0,
        allow_loose_escapes => 0,
        allow_whitespace => 0,
        blank_is_undef => 0,
        empty_is_undef => 0,
        verbatim => 0,
    };
};

# Specify columns for the Friends table export
around _build_columns => sub {
    return {
        friend_id => 1,
        first_name => 2,
        last_name => 3,
        spouse_first_name => 4,
        spouse_last_name => 5,
        street_address => 6,
        zip => 8,
        registered_voter => 7,
    };
};

# The Friends table export doesn't have a header
around _build_skip_header => sub {
    return 0;
};

# Customize the underlying method by checking for valid records and returning
# an FOEGCL::GOTV::Membership record
around next_record => sub {
    my $orig = shift;
    my $self = shift;
    
    my $record;
    do {
        $record = $self->$orig()
            or return;
    }
    while ! $self->_record_is_valid($record);
    
    my @friends = ();
    push @friends, $self->_friend_from_record($record);
    push @friends, $self->_friend_from_record($record, $SPOUSE_RECORD) if
        defined $record->{ spouse_first_name }
        && defined $record->{ spouse_last_name };
    
    return FOEGCL::GOTV::Membership->new(
        membership_id => $friends[0]->friend_id,
        friends => \@friends
    );
};

# Test the validity of a CSV row's values
sub _record_is_valid {
    my $self = shift;
    my $record = shift;
    
    return 1 if 
        defined $record->{ friend_id }
        && defined $record->{ first_name }
        && defined $record->{ last_name }
        && defined $record->{ street_address }
        && defined $record->{ zip };
        
    return 0;
}

# Build an FOEGCL::GOTV::Friend object from a CSV record
sub _friend_from_record {
    my $self = shift;
    my $record = shift;
    my $spouse_record = shift;
    
    # Set the base fields
    my %friend = (
        friend_id => $record->{ friend_id },
        street_address => FOEGCL::GOTV::StreetAddress->clean(
            $record->{ street_address }
        ),
        zip => $record->{ zip },
        registered_voter => ($record->{ registered_voter } eq 'TRUE' ? 1 : 0),
    );
    
    # Add the name fields, either the primary the spouse
    @friend{qw( first_name last_name )} = 
        (! defined $spouse_record || ! $spouse_record) ?
            @{ $record }{qw( first_name last_name )}
            : @{ $record }{qw( spouse_first_name spouse_last_name )};
    
    return FOEGCL::GOTV::Friend->new(%friend);
}

1;

=head1 NAME

FOEGCL::GOTV::MembershipProvider - Iteration over Memberships in a Membership CSV.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This module extends from L<FOEGCL::CSVProvider>, and provides the configuration
options specific to the Membership CSV file, which is created by exporting the
Friends table in the Access Database to Text.

It automatically creates a L<FOEGCL::GOTV::Membership> object for each valid CSV
row.

    use FOEGCL::GOTV::MembershipProvider;

    my $membership_provider = FOEGCL::GOTV::MembershipProvider->new(
        datafile => 'Friends.txt'
    );
    
    while (my $membership = $membership_provider->next_record) {
        say $membership->membership_id;
    }

=head1 ATTRIBUTES

  This module extends from L<FOEGCL::CSVProvider> and adds no attributes of its
  own.

=head1 METHODS

=head2 next_record

  This method returns the next valid membership from the CSV as an
  L<FOEGCL::GOTV::Membership> object.

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
