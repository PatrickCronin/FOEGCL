package FOEGCL::GOTV::VoterStore;

use Moo;
use MooX::Types::MooseLike::Base qw( :all );
use FOEGCL::ItemStore;
use FOEGCL::GOTV::StreetAddress;
use List::Util qw( any );

our $VERSION = '0.01';

has _item_store => ( is => 'ro', isa => InstanceOf[ 'FOEGCL::ItemStore' ], builder => 1 );

# Create the voter store as a specifically-formatted ItemStore
sub _build__item_store {
    my $self = shift;
    
    return FOEGCL::ItemStore->new(
        index_keys => [ qw(last_name first_name zip) ],
        case_sensitive => 0,
    );
}

# Fill the voter store from a FOEGCL::VoterProvider object
sub load_from_provider {
    my $self = shift;
    my $provider = shift;
    
    while (my $voter = $provider->next_record) {
        $self->_item_store->add_item($voter);
    }
}

# Check if any provided Friends match the index keys AND street_address of any
# already-stored Voters without user assistance.
sub any_friends_match_direct {
    my $self = shift;
    my @friends = @_;
    
    return any {
        $self->has_voter_like_friend($_)
    } @friends;
}

# Check if the provided Friend matches the index keys AND street_address of any
# already-stored Voters without user assistance.
sub has_voter_like_friend {
    my $self = shift;
    my $friend = shift;

    my $similar_voters = $self->_item_store->retrieve_items_like_item($friend);
    
    my $friend_street_address = $self->_prepare_street_address_for_comparison(
        $friend->street_address
    );
    
    return any {
        $friend_street_address eq
            $self->_prepare_street_address_for_comparison($_->street_address)
    } @$similar_voters;
}

# A street address can contain many abbreviations. In order to compare two
# street addresses to see if they're the same, "standardize" both of them
# according to USPS Publication 28, and force lower case.
sub _prepare_street_address_for_comparison {
    my $self = shift;
    my $street_address = shift;
    
    return lc FOEGCL::GOTV::StreetAddress->standardize($street_address);
}

# Check if any provided Friends match the index keys AND street_address of any
# already-stored Voters with user assistance.
sub any_friends_match_assisted {
    my $self = shift;
    my @friends = @_;

    return any {
        $self->_friend_match_assisted($_)
    } @friends;
}

# Check if the provided Friend matches the index keys AND street_address of any
# already-stored Voters with user assistance.
sub _friend_match_assisted {
    my $self = shift;
    my $friend = shift;

    my $similar_voters = $self->_item_store->retrieve_items_like_item($friend)
        or return;
        
    return 1 if
        $self->_user_determine_voter_friend_match($friend, $similar_voters);
        
    return;
}

# Prompt the user to manually determine if any of the selected stored Voters
# match the provided Friend.
sub _user_determine_voter_friend_match {
    my $self = shift;
    my $friend = shift;
    my $similar_voters = shift;

    PROMPT:
    while (1) {
        print "\n", q{-} x 40, "\n";
        print "No perfect match was found for the following Friend's street address:\nMatch: " . $friend->street_address . "\n";
        print "Do any of the following voter records match?\n";
        my $voter_num = 1;
        foreach my $voter (@$similar_voters) {
            print "$voter_num: " . $voter->street_address . "\n";
            $voter_num++;
        }
        print "\n";
        print "Type the number of the matching record, or leave blank for none: ";
        my $user_input = <STDIN>;
        chomp $user_input;
        
        return if $user_input eq '';
        return $similar_voters->[ $user_input - 1 ] if
            $user_input =~ m/^\d+$/ && $user_input <= @$similar_voters;
        
        print "Input not understood.\n";
    }
}

1;

__END__

=head1 NAME

FOEGCL::GOTV::VoterStore - Indexed Voter storage and related methods.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This module is the basis of the comparison between
L<Friends|FOEGCL::GOTV::Friend> in the Membership Database and
L<Voters|FOEGCL::GOTV::Voter> on the Voter Registration Roll. This module stores
Voters according to their last name, first name and ZIP Code in a case
insensitive way, and provides methods (both automated and those requiring user
input) for attempting to match up Voters with Friends. 

    use FOEGCL::GOTV::VoterStore;

    my $voter_store = FOEGCL::GOTV::VoterStore->new();
    
    my $voter_provider = FOEGCL::GOTV::VoterProvider->new(
        datafile => 'VOTEXPRT.CSV',
    );
    $voter_store->load_from_provider($voter_provider);
    
    if ($voter_store->has_voter_like_friend($friend)) {
        say "Found Friend in Voter Registration Roll.";
    }
    
    if ($voter_store->any_friends_match_direct(@friends)) {
        say "At least one of these friends is a registered voter!";
    }

    if ($voter_store->any_friends_match_assisted(@friends)) {
        say "At least one of these friends is a registered voter!";
    }
    
=head1 ACCESSORS

  This module has no accessors.

=head1 METHODS

=head2 load_from_provider
    
    Fill the VoterStore from a L<FOEGCL::GOTV::VoterProvider> object.
    
      $voter_store->load_from_provider($voter_provider);

=head2 any_friends_match_direct

    Checks if any of the provided Friends can be found as Voters in the
    VoterStore. A true result indicates that at least one of them satisfies the
    has_voter_like_friend method (see below).
    
      $voter_store->any_friends_match_direct(@friends);

=head2 any_friends_match_assisted

    Checks if any of the provided Friends can be found as Voters in the
    VoterStore. For each Friend, the user will be prompted to manually determine
    if any of the similar Voters' street addresses should match. You'll
    therefore only want to use this method if the fully automated check
    (any_friends_match_direct) fails first.
    
      $voter_store->any_friends_match_assisted(@friends);

=head2 has_voter_like_friend

    Check if a Friend can be found as a Voter in the VoterStore. A true result
    indicates that the first name, last name, ZIP Code and standardized street
    address all match up exactly.
    
      $voter_store->has_voter_like_friend($friend);

=head1 AUTHOR

Patrick Cronin, C<< <patrick at cronin-tech.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-foegcl at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FOEGCL>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FOEGCL::GOTV::VoterStore

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
