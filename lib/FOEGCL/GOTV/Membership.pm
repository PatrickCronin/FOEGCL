package FOEGCL::GOTV::Membership;

use Moo;
use MooX::Types::MooseLike::Base qw( :all );
use List::Util qw( any );

our $VERSION = '0.01';

has membership_id => ( is => 'ro', isa => Str, required => 1 );
has friends => ( is => 'ro', isa => ArrayRef[ InstanceOf[ 'FOEGCL::GOTV::Friend' ] ], required => 1 );

sub has_registered_voter {
    my $self = shift;
    
    return any { $_->registered_voter } @{ $self->friends };
}

sub registered_voter_friends {
    my $self = shift;
    
    my @registered_voter_friends = grep { $_->registered_voter } @{ $self->friends };
    
    return \@registered_voter_friends;
}

1;

__END__

=head1 NAME

FOEGCL::GOTV::Membership - A Membership class for Get Out the Vote

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This module defines a Membership class, representing a Friend (properly, a
membership) from the Friends' Membership Database.

    use FOEGCL::GOTV::Membership;

    my $membership = FOEGCL::GOTV::Membership->new(
        membership_id => 92914,
        friends => $friends, # an ArrayRef of L<FOEGCL::GOTV::Friend> objects
    );
    
    say $membership->membership_id;
    
    if ($membership->has_registered_voter) {
        my $registered_voter_friends = $membership->registered_voter_friends;
        foreach my $registered_voter_friend (@$registered_voter_friends) {
            say $registered_voter_friend->friend_id;
        }
    }
    else {
        my $friends = $membership->friends;
        foreach my $friend (@$friends) {
            say $friend->friend_id;
        }
    }

=head1 ACCESSORS

=head2 membership_id

  The ID of the membership from the Membership Database. Required. Include with call to new(), read-only thereafter.

=head2 friends

  An ArrayRef of L<FOEGCL::GOTV::Friend> objects belonging to the membership.

=head1 METHODS

=head2 has_registered_voter

  Determine if any of the Membership's Friends are marked as registered voters
  (according to their entry in the Membership Database).
  
    if ($membership->has_registered_voter) {
        say "This membership has at least one registered voter.";
    }

=head2 registered_voter_friends

  Return a ArrayRef containing the Membership's Friends which are registered
  voters (according to their entry in the Membership Database).
  
    my $registered_voter_friends = $membership->registered_voter_friends;

=head1 AUTHOR

Patrick Cronin, C<< <patrick at cronin-tech.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-foegcl at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FOEGCL>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FOEGCL::GOTV::Membership

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
