# Class: gcc
#
# This class installs gcc
#
# Parameters:
#
# Actions:
#   - Install the gcc package
#
# Requires:
#
# Sample Usage:
#
class gcc(
  $gcc_package = $gcc::params::gcc_package,
) inherits gcc::params {
  package { $gcc_package:
    ensure => installed
  }
}
