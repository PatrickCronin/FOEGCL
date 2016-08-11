package FOEGCL::GOTV::VoterHash;

use Moo;
use MooX::Types::MooseLike::Base qw( :all );
use FOEGCL::ItemHash;
use FOEGCL::GOTV::StreetAddress;
use List::Util qw( any );

our $VERSION = '0.01';

has _item_hash => ( is => 'ro', isa => Object, builder => 1 );

sub _build__item_hash {
    my $self = shift;
    
    return FOEGCL::ItemHash->new(
        hash_keys => [ qw(last_name first_name zip) ],
        case_sensitive => 0,
    );
}

sub load_from_provider {
    my $self = shift;
    my $provider = shift;
    
    while (my $voter = $provider->next_record) {
        $self->_item_hash->add_item($voter);
    }
}

sub any_friends_match_direct {
    my $self = shift;
    my @friends = @_;
    
    return any {
        $self->has_voter_like_friend($_)
    } @friends;
}

sub has_voter_like_friend {
    my $self = shift;
    my $friend = shift;

    my $similar_voters = $self->_item_hash->retrieve_items_like_item($friend);
    
    my $friend_street_address = $self->_prepare_street_address_for_comparison(
        $friend->street_address
    );
    
    return any {
        $friend_street_address eq
            $self->_prepare_street_address_for_comparison($_->street_address)
    } @$similar_voters;
}

sub _prepare_street_address_for_comparison {
    my $self = shift;
    my $street_address = shift;
    
    return lc FOEGCL::GOTV::StreetAddress->standardize($street_address);
}

sub any_friends_match_assisted {
    my $self = shift;
    my @friends = @_;

    return any {
        $self->_friend_match_assisted($_)
    } @friends;
}

sub _friend_match_assisted {
    my $self = shift;
    my $friend = shift;

    my $similar_voters = $self->_item_hash->retrieve_items_like_item($friend)
        or return;
        
    return 1 if
        $self->_user_determine_voter_friend_match($friend, $similar_voters);
        
    return;
}

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

FOEGCL::GOTV::VoterHash - The great new FOEGCL::GOTV::VoterHash!

=head1 VERSION

Version 0.01


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use FOEGCL::GOTV::VoterHash;

    my $foo = FOEGCL::GOTV::VoterHash->new();
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

    perldoc FOEGCL::GOTV::VoterHash


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

