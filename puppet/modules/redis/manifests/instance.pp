# == Define: redis::instance
#
# Configure redis instance on an arbitrary port.
#
# === Parameters
#
# [*redis_port*]
#   Accept redis connections on this port.
#   Default: 6379
#
# [*redis_bind_address*]
#   Address to bind to.
#   Default: false, which binds to all interfaces
#
# [*redis_max_memory*]
#   Max memory usage configuration.
#   Default: 4gb
#
# [*redis_max_clients*]
#   Set the redis config value maxclients. If no value provided, it is
#   not included in the configuration for 2.6+ and set to 0 (unlimited)
#   for 2.4.
#   Default: 0 (2.4)
#   Default: nil (2.6+)
#
# [*redis_timeout*]
#   Set the redis config value timeout (seconds).
#   Default: 300
#
# [*redis_loglevel*]
#   Set the redis config value loglevel. Valid values are debug,
#   verbose, notice, and warning.
#   Default: notice
#
# [*redis_databases*]
#   Set the redis config value databases.
#   Default: 16
#
# [*redis_slowlog_log_slower_than*]
#   Set the redis config value slowlog-log-slower-than (microseconds).
#   Default: 10000
#
# [*redis_showlog_max_len*]
#   Set the redis config value slowlog-max-len.
#   Default: 1024
#
# [*redis_password*]
#   Password used by AUTH command. Will be setted if it is not nil.
#   Default: nil
#
# [*redis_saves*]
#   Redis snapshotting parameters. Set to false for no snapshots.
#   Default: ['save 900 1', 'save 300 10', 'save 60 10000']
#
# === Examples
#
# redis::instance { 'redis-6900':
#   redis_port       => '6900',
#   redis_max_memory => '64gb',
# }
#
# === Authors
#
# Thomas Van Doren
#
# === Copyright
#
# Copyright 2012 Thomas Van Doren, unless otherwise noted.
#
define redis::instance (
  $redis_port = $redis::params::redis_port,
  $redis_bind_address = $redis::params::redis_bind_address,
  $redis_max_memory = $redis::params::redis_max_memory,
  $redis_max_clients = $redis::params::redis_max_clients,
  $redis_timeout = $redis::params::redis_timeout,
  $redis_loglevel = $redis::params::redis_loglevel,
  $redis_databases = $redis::params::redis_databases,
  $redis_slowlog_log_slower_than = $redis::params::redis_slowlog_log_slower_than,
  $redis_slowlog_max_len = $redis::params::redis_slowlog_max_len,
  $redis_password = $redis::params::redis_password,
  $redis_saves = $redis::params::redis_saves
  ) {

  # Using Exec as a dependency here to avoid dependency cyclying when doing
  # Class['redis'] -> Redis::Instance[$name]
  Exec['install-redis'] -> Redis::Instance[$name]
  include redis

  $version = $redis::version

  case $version {
    /^2\.4\.\d+$/: {
      if ($redis_max_clients == false) {
        $real_redis_max_clients = 0
      }
      else {
        $real_redis_max_clients = $redis_max_clients
      }
    }
    /^2\.[68]\.\d+$/: {
      $real_redis_max_clients = $redis_max_clients
    }
    default: {
      fail("Invalid redis version, ${version}. It must match 2.4.\\d+ or 2.[68].\\d+.")
    }
  }

  file { "redis-lib-port-${redis_port}":
    ensure => directory,
    path   => "/var/lib/redis/${redis_port}",
  }

  file { "redis-init-${redis_port}":
    ensure  => present,
    path    => "/etc/init.d/redis_${redis_port}",
    mode    => '0755',
    content => template('redis/redis.init.erb'),
    notify  => Service["redis-${redis_port}"],
  }
  file { "redis_port_${redis_port}.conf":
    ensure  => present,
    path    => "/etc/redis/${redis_port}.conf",
    mode    => '0644',
    content => template('redis/redis_port.conf.erb'),
  }

  service { "redis-${redis_port}":
    ensure    => running,
    name      => "redis_${redis_port}",
    enable    => true,
    require   => [ File["redis_port_${redis_port}.conf"], File["redis-init-${redis_port}"], File["redis-lib-port-${redis_port}"] ],
    subscribe => File["redis_port_${redis_port}.conf"],
  }
}
