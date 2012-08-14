# Class: mysql::ruby
#
# installs the ruby bindings for mysql
#
# Parameters:
#   [*ensure*]       - ensure state for package.
#                        can be specified as version.
#   [*package_name*] - name of package
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::ruby (
  $package_name     = $mysql::params::ruby_package_name,
  $package_provider = $mysql::params::ruby_package_provider,
  $package_ensure   = 'present'
) inherits mysql::params {

  package{ 'ruby_mysql':
    name     => $package_name,
    ensure   => $package_ensure,
    provider => $package_provider,
  }

}
