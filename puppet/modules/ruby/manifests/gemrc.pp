# Manage global gemrc configuration
#
# This class allows the management of entries in /etc/gemrc
# That can be useful when, e.g. configuring a rubygems proxy.

# === Parameters
#
#  [*sources*]
#    A YAML array of remote gem repositories to install gems from
#
#  [*verbose*]
#    Verbosity of the gem command. false, true, and :really are the levels
#
#  [*update_sources*]
#    Enable/disable automatic updating of repository metadata
#
#  [*backtrace*]
#    Print backtrace when RubyGems encounters an error
#
#  [*gempath*]
#    The paths in which to look for gems
#
#  [*disable_default_gem_server*]
#    Force specification of gem server host on push
#
#  [*gem_command*]
#    A string containing arguments for the specified gem command
#    This takes an array of Hashes, i.e.:
#
#    gem_command => {
#      'gem'  => [ 'no-ri', 'http-proxy=http://waf-proxy' ],
#      'push' => [ 'host=https://our.rubygems.host' ],
#    }

class ruby::gemrc (
  $sources                    = undef,
  $verbose                    = undef,
  $update_sources             = undef,
  $backtrace                  = undef,
  $gempath                    = undef,
  $gem_command                = undef,
  $gemrc                      = $::ruby::params::gemrc,
  $owner                      = 'root',
  $group                      = 'root',
  $mode                       = '0644',
  $disable_default_gem_server = undef
) inherits ruby::params {

  if $verbose != undef and $verbose != ':really' {
    validate_bool($verbose)
  }
  if $update_sources {
    validate_bool($update_sources)
  }
  if $backtrace {
    validate_bool($backtrace)
  }
  if $disable_default_gem_server {
    validate_bool($disable_default_gem_server)
  }

  $ensure = pick ($sources
      , $verbose
      , $update_sources
      , $backtrace
      , $gempath
      , $disable_default_gem_server
      , $gem_command
      , 'No need for gemrc.'
  ) ? {
    'No need for gemrc.' => 'absent',
    default              => 'file',
  }

  file { 'gemrc':
    ensure  => $ensure,
    path    => $::ruby::params::gemrc,
    mode    => $mode,
    owner   => $owner,
    group   => $group,
    content => template('ruby/gemrc.yaml.erb'),
  }
}
