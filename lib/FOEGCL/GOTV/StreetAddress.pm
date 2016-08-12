package FOEGCL::GOTV::StreetAddress;

use Moo;
use Geo::Address::Mail::US;
use Geo::Address::Mail::Standardizer::USPS;

# Clean up the text of a given street address
sub clean {
    my $class_or_self = shift;
    my $street_address = shift
        or return;
    
    # Replace all whitespace with space characters
    $street_address =~ s/ [\f\t\r\n] / /gx;
    
    # Replace repeating whitespace characters with a single space
    $street_address =~ s/ [ ]{2,} / /gx;
    
    # Remove leading and trailing whitespace
    $street_address =~ s/ ^\s+ | \s+$ //gx;

    return $street_address;
}

# Standardize the text of a given street address in accordance with USPS
# Publication 28.
sub standardize {
    my $class_or_self = shift;
    my $street_address = shift
        or return;
    
    my $address = Geo::Address::Mail::US->new(
        street => $street_address,
    );

    my $std = Geo::Address::Mail::Standardizer::USPS->new;
    my $res = $std->standardize($address);
    my $corr = $res->standardized_address;

    return $corr->street;
}

1;

__END__

=head1 NAME

FOEGCL::GOTV::StreetAddress - Methods for processing street addresses.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This module provides methods for processing street addresses.

    use FOEGCL::GOTV::StreetAddress;

    # Use as class methods
    my $cleaned_street_address = FOEGCL::GOTV::StreetAddress->clean(
        $dirty_street_address
    );
    my $standardized_street_address = FOEGCL::GOTV::StreetAddress->standardize(
        $cleaned_street_address
    );

    # Or as instance methods
    my $sa = FOEGCL::GOTV::StreetAddress->new();
    my $cleaned_street_address = $sa->clean($dirty_street_address);
    my $standardized_street_address = $sa->standardize($cleaned_street_address);

=head1 ATTRIBUTES

  This module has no attributes.

=head1 METHODS

=head2 clean

  Cleanup whitespace within a street address.

    my $clean_street_address =
        FOEGCL::GOTV::StreetAddress->clean($street_address);

=head2 standardize

  Use Geo::Address::Mail::Standardizer::USPS to standardize a street address
  according to
  L<USPS Publication 28|http://pe.usps.com/text/pub28/28apc_001.htm>.
  
    my $standardized_street_address =
        FOEGCL::GOTV::StreetAddress->standardize($cleaned_street_address);

=head1 AUTHOR

Patrick Cronin, C<< <patrick at cronin-tech.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-foegcl at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FOEGCL>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FOEGCL::GOTV::StreetAddress

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
