package FOEGCL::App::CompareRegisteredVoters;

use Moo;
use MooX::Types::MooseLike::Base qw( :all );
use FOEGCL::Logger;
use FOEGCL::GOTV::VoterHash;
use FOEGCL::GOTV::MembershipProvider;
use FOEGCL::GOTV::VoterProvider;
use List::Util qw( any );

our $VERSION = '0.01';

has membership_csv => (
    is => 'ro',
    isa => sub {
        die "Membership CSV must be a file readable to the current user."
        unless -e $_[0] && -f $_[0] && -r $_[0]
    },
    required => 1,
);
has voter_csv => (
    is => 'ro',
    isa => sub {
        die "Voter CSV must be a file readable to the current user."
        unless -e $_[0] && -f $_[0] && -r $_[0]
    },
    required => 1,
);
has logfile => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has _voter_hash => ( is => 'ro', isa => Object, builder => 1 );
has _membership_provider => ( is => 'ro', isa => Object, lazy => 1, builder => 1 );
has _voter_provider => ( is => 'ro', isa => Object, lazy => 1, builder => 1 );

sub _build__voter_hash {
    my $self = shift;
    
    return FOEGCL::GOTV::VoterHash->new;
}

sub _build__membership_provider {
    my $self = shift;

    return FOEGCL::GOTV::MembershipProvider->new(
        datafile => $self->membership_csv
    );
}

sub _build__voter_provider {
    my $self = shift;

    return FOEGCL::GOTV::VoterProvider->new(
        datafile => $self->voter_csv
    );
}

sub run {
    my $self = shift;
    
    my $logger = FOEGCL::Logger->new(
        logfile => $self->logfile
    );
    
    # Read voters into memory
    $self->_load_all_voters;
    
    # For each membership, verify registered voter status
    MEMBERSHIP:
    while (my $membership = $self->_membership_provider->next_record) {
        if ($membership->has_registered_voter) {
            if ($self->_membership_has_direct_registered_voter_hit(@{ $membership->registered_voter_friends })
                || $self->_membership_has_assisted_registered_voter_hit(@{ $membership->registered_voter_friends })
            ) {
                $logger->add(
                    $membership->membership_id . ' Perfect.'
                );
            }
            else {
                $logger->add(
                    $membership->membership_id .
                        ' Check: Voter registration record not found, but expected.'
                );
            }
        }
        else {
            if ($self->_membership_has_direct_registered_voter_hit(@{ $membership->friends })
                || $self->_membership_has_assisted_registered_voter_hit(@{ $membership->friends })
            ) {
                $logger->add(
                    $membership->membership_id .
                        ' Check: Voter registration record found, but not expected.'
                );
            }
            else {
                $logger->add(
                    $membership->membership_id .
                        ' Confirm: No voter registration record found, and none expected.'
                );
            }
        }
    }
}

sub _load_all_voters {
    my $self = shift;

    while (my $voter = $self->_voter_provider->next_record) {
        $self->_voter_hash->add_item($voter);
    }
}

sub _membership_has_direct_registered_voter_hit {
    my $self = shift;
    my @registered_voter_friends = @_;
    
    return any {
        $self->_voter_hash->has_voter_like($_)
    } @registered_voter_friends;
}

sub _membership_has_assisted_registered_voter_hit {
    my $self = shift;
    my @registered_voter_friends = @_;

    return any {
        $self->_friend_has_assisted_registered_voter_hit($_)
    } @registered_voter_friends;
}

sub _friend_has_assisted_registered_voter_hit {
    my $self = shift;
    my $friend = shift;

    my $hashed_voters = $self->_voter_hash->retrieve_voters_like($friend)
        or return;
        
    return 1 if
        $self->_friend_has_assisted_voter_hit($friend, $hashed_voters);
        
    return;
}

sub _friend_has_assisted_voter_hit {
    my $self = shift;
    my $friend = shift;
    my $hashed_voters = shift;

    PROMPT:
    while (1) {
        print "\n", q{-} x 40, "\n";
        print "No perfect match was found for the following Friend's street address:\nMatch: " . $friend->street_address . "\n";
        print "Do any of the following voter records match?\n";
        my $voter_num = 1;
        foreach my $voter (@$hashed_voters) {
            print "$voter_num: " . $voter->street_address . "\n";
            $voter_num++;
        }
        print "\n";
        print "Type the number of the matching record, or leave blank for none: ";
        my $user_input = <STDIN>;
        chomp $user_input;
        
        return if $user_input eq '';
        return $hashed_voters->[ $user_input - 1 ] if
            $user_input =~ m/^\d+$/ && $user_input <= @$hashed_voters;
        
        print "Input not understood.\n";
    }
}

1;

__END__

=head1 NAME

FOEGCL::App::CompareRegisteredVoters - The great new FOEGCL::App::CompareRegisteredVoters!

=head1 VERSION

Version 0.01


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use FOEGCL::App::CompareRegisteredVoters;

    my $foo = FOEGCL::App::CompareRegisteredVoters->new();
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

    perldoc FOEGCL::App::CompareRegisteredVoters


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

