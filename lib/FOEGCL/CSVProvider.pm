package FOEGCL::CSVProvider;

use Moo;
use MooX::Types::MooseLike::Base qw( :all );
use Carp qw( carp croak );
use Text::CSV_XS;
use English qw( -no_match_vars );

our $VERSION = '0.01';

has datafile => (
    is => 'ro',
    required => 1,
    isa => sub { die "datafile must be a readable file" unless -e $_[0] && -f $_[0] && -r $_[0]; },
);
has columns => ( is => 'ro', isa => HashRef[ Int ], builder => 1 ); # 1-based
has skip_header => ( is => 'ro', isa => Int, builder => 1 );
has _datafile_fh => ( is => 'ro', isa => FileHandle, lazy => 1, builder => 1 );
has _parser_options => ( is => 'ro', isa => HashRef, builder => 1 );
has _parser => (
    is => 'ro',
    isa => sub {
        die "_parser must be a Text::CSV_XS object" unless ref $_[0] eq 'Text::CSV_XS'
    },
    lazy => 1,
    builder => 1
);

# Ensure we have at least 1 column defined
sub BUILD {
    my $self = shift;
    my $args = shift;
    
    if (scalar keys %{ $self->{columns} } == 0) {
        croak "Can't create a " . __PACKAGE__ . " object without columns!";
    }
}

# Close the _datafile_fh if it's open
sub DEMOLISH {
    my $self = shift;
    
    if (defined $self->_datafile_fh) {
        close $self->_datafile_fh
            or carp "Failed to close datafile: $OS_ERROR";
    }
    
    return;
}

sub _build__parser_options {
    return {
        binary => 1,
        auto_diag => 1,
        diag_verbose => 1,
        eol => qq{\n},
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
}

sub _build_columns {
    return {};
}

# By default, don't skip the header
sub _build_skip_header {
    return 0;
}

# Prepare the datafile for reading
sub _build__datafile_fh {
    my $self = shift;
    
    open my $fh, '<:encoding(utf8)', $self->datafile
        or croak 'Failed to open the datafile at ' . $self->datafile . ": $OS_ERROR";
        
    <$fh> if $self->skip_header;
    
    return $fh;
};

# Instantiate the Text::CSV_XS object
sub _build__parser {
    my $self = shift;
    
    return Text::CSV_XS->new($self->_parser_options);
}

sub next_record {
    my $self = shift;

    my $row = $self->_parser->getline($self->_datafile_fh);
    return if ! defined $row;
    
    return $self->_build_record($row);
}

sub _build_record {
    my $self = shift;
    my $row = shift;

    my %record = ();
    foreach my $column_name (keys %{ $self->columns }) {
        $record{$column_name} = $self->_trim(
            $row->[ $self->columns->{ $column_name } - 1 ]
        );
    }
    
    return \%record;
}

sub _trim {
    my $self = shift;
    my $text = shift
        or return;
    
    $text =~ s/^\s+|\s+$//g;
    
    return $text;
}


sub _clean_street_address {
    my $self = shift;
    my $street_address = shift;

    $street_address =~ s/[\f\t\r\n]/ /g;   # Replace all whitespace with space characters
    $street_address =~ s/ {2,}/ /g;        # Replace repeating whitespace characters with a single space
    $street_address = $self->_trim($street_address);

    return $street_address;
}

1;

__END__

=head1 NAME

FOEGCL::CSVProvider - The great new FOEGCL::CSVProvider!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use FOEGCL::CSVProvider;

    my $foo = FOEGCL::CSVProvider->new();
    ...

=head1 ATTRIBUTES

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

    perldoc FOEGCL::CSVProvider


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

