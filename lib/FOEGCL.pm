package FOEGCL;

use Modern::Perl;

our $VERSION = '0.01';

1;

__END__

=head1 NAME

FOEGCL - utilities for the Friends of the East Greenbush Community Library.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This distribution provides command line tools and libraries to assist the
Friends of the East Greenbush Community Library simplify manual tasks.

=head2 COMMAND LINE TOOLS

=over 4

=item B<compare-registered-voters>

compare-registered-voters - Compare Friends' voter registration statuses against
    the voter registration roll

=back

=head2 LIBRARIES

=over 4

=item B<FOEGCL::CSVProvider>

FOEGCL::CSVProvider - an extendable object that iterates over the rows of a CSV
file.

=item B<FOEGCL::ItemStore>

FOEGCL::ItemStore - an extendable object that stores items with a set of similar
characteristics.

=item B<FOEGCL::Logger>

FOEGCL::Logger - an extendable object that provides output logging services.

=item FOEGCL::GOTV::____

FOEGCL::GOTV::_____ - a set of modules that assist the compare-registered-voters
program.

=back

=head1 AUTHOR

Patrick Cronin, C<< <patrick at cronin-tech.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-foegcl at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FOEGCL>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FOEGCL

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
