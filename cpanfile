=comment

Install all dependencies with:

    cpanm --installdeps . --with-develop --with-all-features

Note on version specification syntax:

    # Any version of My::Module equal or higher than 0.01 is required
    requires 'My::Module' => '0.01';

    # ditto
    requires 'My::Module' => '>= 0.01';

    # Exactly My::Module v0.01 is required
    requires 'My::Module' => '== 0.01';

See https://metacpan.org/pod/CPAN::Meta::Spec#VERSION-NUMBERS for details.

=cut

requires 'perl', '5.42.2';
requires "Dancer2" => "2.1.0";
requires 'YAML';
requires 'Crypt::Passphrase';
requires 'Crypt::Argon2';
requires 'Plack';
requires 'Starman';
requires 'Dancer2::Plugin::Database';
requires 'Dancer2::Plugin::CryptPassphrase';
requires 'Dancer2::Plugin::Syntax::GetPost';
requires 'Dancer2::Plugin::Syntax::ParamKeywords';
requires 'Dancer2::Plugin::Auth::Tiny';
requires 'DBD::SQLite';

feature 'accelerate', 'Accelerate Dancer2 app performance with XS modules' => sub {
    requires "URL::Encode::XS"         => "0";
    requires 'CBOR::XS'                => "0";
    requires "CGI::Deurl::XS"          => "0";
    requires "YAML::XS"                => "0";
    requires "Class::XSAccessor"       => "0";
    requires "Cpanel::JSON::XS"        => "0";
    requires "Crypt::URandom"          => "0";
    requires 'HTTP::Parser::XS'        => "0";
    requires "HTTP::XSCookies"         => "0";
    requires "HTTP::XSHeaders"         => "0";
    requires "Math::Random::ISAAC::XS" => "0";
    requires "MooX::TypeTiny"          => "0";
    requires "Type::Tiny::XS"          => "0";
    requires "Unicode::UTF8"           => "0";
};

on 'test' => sub {
    requires 'Test::Most';
};

on 'develop' => sub {
    requires 'Data::Printer';
    requires 'Perl::Tidy';
};

