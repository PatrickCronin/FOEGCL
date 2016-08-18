#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 13;

sub not_in_file_ok {
    my ($filename, %regex) = @_;
    open( my $fh, '<', $filename )
        or die "couldn't open $filename for reading: $!";

    my %violated;

    while (my $line = <$fh>) {
        while (my ($desc, $regex) = each %regex) {
            if ($line =~ $regex) {
                push @{$violated{$desc}||=[]}, $.;
            }
        }
    }

    if (%violated) {
        fail("$filename contains boilerplate text");
        diag "$_ appears on lines @{$violated{$_}}" for keys %violated;
    } else {
        pass("$filename contains no boilerplate text");
    }
}

sub module_boilerplate_ok {
    my ($module) = @_;
    not_in_file_ok($module =>
        'the great new $MODULENAME'   => qr/ - The great new /,
        'boilerplate description'     => qr/Quick summary of what the module/,
        'stub function definition'    => qr/function[12]/,
    );
}

not_in_file_ok('README.pod' =>
"The README is used..."       => qr/The README is used/,
"'version information here'"  => qr/to provide version information/,
);

not_in_file_ok(Changes =>
"placeholder date/time"       => qr(Date/time)
);

module_boilerplate_ok('lib/FOEGCL/CSVProvider.pm');
module_boilerplate_ok('lib/FOEGCL/GOTV/Friend.pm');
module_boilerplate_ok('lib/FOEGCL/GOTV/Membership.pm');
module_boilerplate_ok('lib/FOEGCL/GOTV/MembershipProvider.pm');
module_boilerplate_ok('lib/FOEGCL/GOTV/StreetAddress.pm');
module_boilerplate_ok('lib/FOEGCL/GOTV/Voter.pm');
module_boilerplate_ok('lib/FOEGCL/GOTV/VoterProvider.pm');
module_boilerplate_ok('lib/FOEGCL/GOTV/VoterStore.pm');
module_boilerplate_ok('lib/FOEGCL/ItemStore.pm');
module_boilerplate_ok('lib/FOEGCL/Logger.pm');
module_boilerplate_ok('lib/FOEGCL.pm');
