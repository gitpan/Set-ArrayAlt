
use ExtUtils::MakeMaker;

WriteMakefile(
        NAME             => 'Set::ArrayAlt',
        VERSION          => '1.00',
        ($] >= 5.005
        ? (ABSTRACT=>'arrays as objects with list/set operations',
           AUTHOR  =>'Sullivan Beck (sbeck@cpan.org)')
        : ()),
        'dist' => {COMPRESS=>'gzip',SUFFIX=>'gz'},
        PL_FILES  => {},
        PREREQ_PM => {
                'Sort::DataTypes'     => '0',
                'Test::More'          => '0',
                'Test::Pod'           => '0',
                'Test::Pod::Coverage' => '0',
        },
);
