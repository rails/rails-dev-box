# Class: mysql::python
#
# This class installs the python libs for mysql.
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
class mysql::python(
  $package_name   = $mysql::params::python_package_name,
  $package_ensure = 'present'
) inherits mysql::params {

  package { 'python-mysqldb':
    name   => $package_name,
    ensure => $package_ensure,
  }

}
