class postgresql (
  $client_package = $postgresql::params::client_package,
  $version = $postgresql::params::version

) inherits postgresql::params {

  package { "postgresql-client-$version":
    name    => sprintf("%s-%s", $client_package, $version),
    ensure  => present,
  }

}
