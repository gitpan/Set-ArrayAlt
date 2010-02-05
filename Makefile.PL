
use ExtUtils::MakeMaker;
use 5.004;
use strict;
use warnings;
my %requires = (
                 'Sort::DataTypes'          => '0',
                 'Storable'                 => '0',
                 'Test::More'               => '0',
                 'Test::Pod'                => '0',
                 'Test::Pod::Coverage'      => '0',
               );


WriteMakefile(
        NAME             => 'Set::ArrayAlt',
        VERSION          => '1.01',
        ($] >= 5.004
        ? (ABSTRACT=>'full set of list/set operations for arrays',
           AUTHOR  =>'Sullivan Beck (sbeck@cpan.org)')
        : ()),
        'dist' => {COMPRESS=>'gzip',SUFFIX=>'gz'},
        PL_FILES  => {},
        PREREQ_PM => \%requires,
);
