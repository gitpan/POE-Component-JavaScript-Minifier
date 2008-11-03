use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'POE::Component::JavaScript::Minifier',
    license             => 'perl',
    dist_author         => q|Zoffix <'zoffix@cpan.org'>|,
    dist_version_from   => 'lib/POE/Component/JavaScript/Minifier.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'POE'                                      => 0.9999,
        'POE::Component::NonBlockingWrapper::Base' => 0.002,
        'LWP::UserAgent'                           => 2.036,
        'JavaScript::Minifier'                     => 1.05,
    },
    add_to_cleanup      => [ 'POE-Component-JavaScript-Minifier-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
