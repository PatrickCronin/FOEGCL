package FOEGCL::GOTV::VoterProvider;

use Moo;
extends 'FOEGCL::CSVProvider';
use FOEGCL::GOTV::StreetAddress;
use FOEGCL::GOTV::Voter;

our $VERSION = '0.01';

# Specify parser options for the received voter registration file
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

# Specify columns for the recieved voter registration file
around _build_columns => sub {
    return {
        voter_registration_id => 1,
        first_name => 2,
        last_name => 4,
        street_number => 6,
        street_name => 8,
        apartment => 9,
        zip => 14,
    };
};

# The voter registration file didn't come with a header
around _build_skip_header => sub {
    return 0;
};

# Customize the underlying method by returning an FOEGCL::GOTV::Voter object
around next_record => sub {
    my $orig = shift;
    my $self = shift;
    
    my $record = $self->$orig
        or return;
        
    return $self->_voter_from_record($record);
};

# Build an FOEGCL::GOTV::Voter object from a CSV record
sub _voter_from_record {
    my $self = shift;
    my $record = shift;
    
    my %voter = (
        voter_registration_id => $record->{ voter_registration_id },
        first_name => $record->{ first_name },
        last_name => $record->{ last_name },
        street_address => FOEGCL::GOTV::StreetAddress->clean(
            join ' ', grep {
                defined $_
            } (
                $record->{ street_number }, $record->{ street_name }, $record->{ apartment }
            )
        ),
        zip => $record->{ zip },
    );
    
    return FOEGCL::GOTV::Voter->new(%voter);
}

1;

__END__

=head1 NAME

FOEGCL::GOTV::VoterProvider - Iteration over Voters in a Voter Registration CSV.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This module extends from L<FOEGCL::CSVProvider>, and provides the configuration
options specific to the Voter Registration Export file, which was recieved
through assistance from the Library Director.

It generates a L<FOEGCL::GOTV::Voter> object for each CSV row.

    use FOEGCL::GOTV::VoterProvider;

    my $voter_provider = FOEGCL::GOTV::VoterProvider->new(
        datafile => 'VOTEXPRT.CSV'
    );
    
    while (my $voter = $voter_provider->next_record) {
        say $voter->voter_registration_id;
    }

=head1 ATTRIBUTES

  This module extends from L<FOEGCL::CSVProvider> and adds no attributes of its
  own.

=head1 METHODS

=head2 next_record

  This method returns the next voter from the CSV as an
  L<FOEGCL::GOTV::Voter> object. Note that this module creates the street
  address for the voter by appending the street number, street name, and
  apartment number if any.
  
    my $next_voter = $voter_provider->next_record;

=head1 AUTHOR

Patrick Cronin, C<< <patrick at cronin-tech.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-foegcl at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FOEGCL>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FOEGCL::GOTV::VoterProvider

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
