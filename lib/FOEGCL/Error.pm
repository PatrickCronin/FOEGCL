package FOEGCL::Error;

use Moo;
extends 'Throwable::Error';

our $VERSION = '0.01';

1;

__END__


=head1 NAME

FOEGCL::Error - A generic exception.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use FOEGCL::CSVProvider;
    use Try::Tiny;
    use Scalar::Util qw( blessed );
    
    try {
        $csv = FOEGCL::CSVProvider->new(
            datafile => 'file.csv'
        );
    }
    catch {
        die $_ unless blessed $_;
        die $_ if $_->isa('FOEGCL::Error');
        
        # handle other exceptions
    }

=head1 DESCRIPTION

This class represents an error.

=head1 ATTRIBUTES

This class extends L<Throwable::Error|Throwable::Error> and does not add any additional attributes.

=head1 METHODS

This class extends L<Throwable::Error|Throwable::Error> and does not add any additional methods.

=head1 AUTHOR

Patrick Cronin, C<< <patrick at cronin-tech.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-foegcl at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FOEGCL>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

This class is very much copied from L<https://www.maxmind.com|MaxMind>'s
L<GeoIP2::Error::Generic|GeoIP2::Error::Generic> class.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FOEGCL::Error

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
