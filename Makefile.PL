use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::ShareDir::Install;

install_share dist => 'share';

WriteMakefile(
    NAME             => 'FOEGCL',
    AUTHOR           => q{Patrick Cronin <patrick@cronin-tech.com>},
    VERSION_FROM     => 'lib/FOEGCL.pm',
    ABSTRACT_FROM    => 'lib/FOEGCL.pm',
    LICENSE          => 'gpl_3',
    EXE_FILES        => [ 'bin/compare-registered-voters' ],
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Moo' => 2.002004,
        'MooX::Options' => 4.023,
        'MooX::Types::MooseLike::Base' => 0.29,
        'File::Share' => 0.25,
        'Path::Tiny' => 0.096,
        'Text::CSV_XS' => 1.24,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'FOEGCL-*' },
);

package MY;
use File::ShareDir::Install 'postamble';