# Class: mysql::java
#
# This class installs the mysql-java-connector.
#
# Parameters:
#   [*java_package_name*]  - The name of the mysql java package.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::java (
  $package_name   = $mysql::params::java_package_name,
  $package_ensure = 'present'
) inherits mysql::params {

  package { 'mysql-connector-java':
    ensure => $package_ensure,
    name   => $package_name,
  }

}
