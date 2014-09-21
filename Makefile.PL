use ExtUtils::MakeMaker;

my $defines = $Config::Config{nvtype} eq 'long double'
                ? '-DNV_IS_LONG_DOUBLE'
                : $Config::Config{nvtype} eq '__float128' ? '-DNV_IS_FLOAT128'
                                                          : '-DNV_IS_DOUBLE';

#Data::Float is handy for testing, but won't work with powerpc 'long double' builds.
my $prereq =  $Config::Config{nvsize} > 8 && $Config::Config{osvers} =~ /powerpc/i
                    ? {}
                    : {'Data::Float' => '0.012'};

my %options = %{
{
  'NAME' => 'Math::NV',
  'VERSION_FROM' => 'NV.pm',
  'PREREQ_PM' => $prereq,
  'LIBS' => [
    '-lm'
  ],
  'INC' => '',
  'DEFINE' => $defines,
  'LICENSE'  => 'perl',
  META_MERGE => {
   'meta-spec' => { version => 2 },
    resources => {
      repository => {
        type => 'git',
        url => 'https://github.com/sisyphus/math-nv.git',
        web => 'https://github.com/sisyphus/math-nv',
      },
    },
  },
}
};
WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
