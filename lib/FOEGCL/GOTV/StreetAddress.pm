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