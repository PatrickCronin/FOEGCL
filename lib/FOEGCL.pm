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

=item L<FOEGCL::CSVProvider>

FOEGCL::CSVProvider - an extendable class that iterates over the rows of a CSV
file.

=item L<FOEGCL::ItemStore>

FOEGCL::ItemStore - an extendable class that stores items with a set of similar
characteristics.

=item L<FOEGCL::Logger>

FOEGCL::Logger - an extendable class that provides output logging services.

=item L<FOEGCL::GOTV>

FOEGCL::GOTV - a set of modules that assist the compare-registered-voters
program:

    L<FOEGCL::GOTV::Friend> - A Friend class for Get Out the Vote
    L<FOEGCL::GOTV::Membership> - A Membership class for Get Out the Vote
    L<FOEGCL::GOTV::MembershipProvider> - Iteration over Memberships in a Membership CSV
    L<FOEGCL::GOTV::StreetAddress> - Methods for processing street addresses
    L<FOEGCL::GOTV::Voter> - A Voter class for Get Out the Vote
    L<FOEGCL::GOTV::VoterProvider> - Iteration over Voters in a Voter Registration CSV
    L<FOEGCL::GOTV::VoterStore> - Indexed Voter storage and related methods

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
