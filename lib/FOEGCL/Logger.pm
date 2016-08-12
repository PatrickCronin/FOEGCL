package FOEGCL::Logger;

use Moo;
use MooX::Types::MooseLike::Base qw( :all );
use Carp qw( carp croak );
use English qw( -no_match_vars );

our $VERSION = '0.01';

has logfile => (
    is => 'ro',
    isa => Str,
    required => 1,
);
has _logfile_fh => ( is => 'ro', isa => FileHandle, lazy => 1, builder => 1 );

# Prepare the logfile for writing
sub _build__logfile_fh {
    my $self = shift;

    if (-e $self->logfile) {
        if (! -f $self->logfile || ! -w $self->logfile) {
            croak "If logfile path exists, it must be a file writable by you, so you can overwrite it.";
        }
    }

    open my $fh, '>:encoding(utf8)', $self->logfile
        or croak 'Failed to open the logfile at ' . $self->logfile . ": $OS_ERROR";

    return $fh;
};

# Close the _logfile_fh if it's open
sub DEMOLISH {
    my $self = shift;
    
    if (defined $self->_logfile_fh) {
        close $self->_logfile_fh
            or carp "Failed to close logfile: $OS_ERROR";
    }
    
    return;
}

# Write some text to the logfile
sub log {
    my $self = shift;
    my $text = shift
        or return;
    
    say { $self->_logfile_fh } $text;
}

1;

__END__

=head1 NAME

FOEGCL::Logger - Output logging services.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This module manages logging program events to an output file.

    use FOEGCL::Logger;

    my $logger = FOEGCL::Logger->new(
        logfile => 'output.log'
    );

    $logger->log("Friend found as Voter!");

=head1 ACCESSORS

=head2 logfile

  Specify the path the output logfile. Required. Provide with call to new(),
  read-only thereafter.

=head1 METHODS

=head2 log

  Write some text to the logfile.
  
    $logger->log($text);

=head1 AUTHOR

Patrick Cronin, C<< <patrick at cronin-tech.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-foegcl at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FOEGCL>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FOEGCL::Logger

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
