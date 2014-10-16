# PRIVATE CLASS: do not use directly
class postgresql::server::firewall {
  $ensure             = $postgresql::server::ensure
  $manage_firewall    = $postgresql::server::manage_firewall
  $firewall_supported = $postgresql::server::firewall_supported
  $port               = $postgresql::server::port

  if ($manage_firewall and $firewall_supported) {
    if ($ensure == 'present' or $ensure == true) {
      firewall { "$port accept - postgres":
        port   => $port,
        proto  => 'tcp',
        action => 'accept',
      }
    } else {
      firewall { "$port accept - postgres":
        ensure => absent,
      }
    }
  }
}
