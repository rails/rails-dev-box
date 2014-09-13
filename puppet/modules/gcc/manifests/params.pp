# Class: gcc::params
#
# This class manages parameters for the gcc module
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class gcc::params {
  case $::osfamily {
    'RedHat': {
      $gcc_package = [ 'gcc', 'gcc-c++' ]
    }
    'Debian': {
      $gcc_package = [ 'gcc', 'build-essential' ]
    }
    default: {
      fail("Class['gcc::params']: Unsupported osfamily: ${::osfamily}")
    }
  }
}
