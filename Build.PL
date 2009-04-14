
use Module::Build;

my $build = Module::Build->new(
        license            => 'perl',
        dist_version       => '1.00',
        dist_author        => 'Sullivan Beck <sbeck@cpan.org>',
        module_name        => 'Set::ArrayAlt',
        dist_abstract      => 'arrays as objects with list/set operations',
        requires           => {
                'perl'                => '5.6.0',
                'Sort::DataTypes'     => '0',
        },
        build_requires     => {
        },
        build_recommends   => {
                'Test::More'          => '0',
                'Test::Pod'           => '0',
                'Test::Pod::Coverage' => '0',
        },
        sign               => 1,
);

$build->create_build_script;
