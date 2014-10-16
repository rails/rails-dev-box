# Manage a postgresql.conf entry. See README.md for more details.
define postgresql::server::config_entry (
  $ensure = 'present',
  $value  = undef,
  $path   = false
) {
  $postgresql_conf_path = $postgresql::server::postgresql_conf_path

  $target = $path ? {
    false   => $postgresql_conf_path,
    default => $path,
  }

  Exec {
    logoutput => 'on_failure',
  }

  case $name {
    /data_directory|hba_file|ident_file|include|listen_addresses|port|max_connections|superuser_reserved_connections|unix_socket_directory|unix_socket_group|unix_socket_permissions|bonjour|bonjour_name|ssl|ssl_ciphers|shared_buffers|max_prepared_transactions|max_files_per_process|shared_preload_libraries|wal_level|wal_buffers|archive_mode|max_wal_senders|hot_standby|logging_collector|silent_mode|track_activity_query_size|autovacuum_max_workers|autovacuum_freeze_max_age|max_locks_per_transaction|max_pred_locks_per_transaction|restart_after_crash|lc_messages|lc_monetary|lc_numeric|lc_time/: {
      Postgresql_conf {
        notify => Class['postgresql::server::service'],
        before => Class['postgresql::server::reload'],
      }
    }

    default: {
      Postgresql_conf {
        notify => Class['postgresql::server::reload'],
      }
    }
  }

  # We have to handle ports in a weird and special way.  On Redhat we either
  # have to create a systemd override for the port or update the sysconfig
  # file.
  if $::osfamily == 'RedHat' {
    if $::operatingsystemrelease =~ /^7/ or $::operatingsystem == 'Fedora' {
      if $name == 'port' {
        file { 'systemd-port-override':
          ensure  => present,
          path    => '/etc/systemd/system/postgresql.service',
          owner   => root,
          group   => root,
          content => template('postgresql/systemd-port-override.erb'),
          notify  => [ Exec['restart-systemd'], Class['postgresql::server::service'] ],
          before  => Class['postgresql::server::reload'],
        }
        exec { 'restart-systemd':
          command     => 'systemctl daemon-reload',
          refreshonly => true,
          path        => '/bin:/usr/bin:/usr/local/bin'
        }
      }
    } else {
      if $name == 'port' {
        # We need to force postgresql to stop before updating the port
        # because puppet becomes confused and is unable to manage the
        # service appropriately.
        exec { 'postgresql_stop':
          command => "service ${::postgresql::server::service_name} stop",
          onlyif  => "service ${::postgresql::server::service_name} status",
          unless  => "grep 'PGPORT=${value}' /etc/sysconfig/pgsql/postgresql",
          path    => '/sbin:/bin:/usr/bin:/usr/local/bin',
          require => File['/etc/sysconfig/pgsql/postgresql'],
        } ->
        augeas { 'override PGPORT in /etc/sysconfig/pgsql/postgresql':
          lens    => 'Shellvars.lns',
          incl    => '/etc/sysconfig/pgsql/*',
          context => '/files/etc/sysconfig/pgsql/postgresql',
          changes => "set PGPORT ${value}",
          require => File['/etc/sysconfig/pgsql/postgresql'],
          notify  => Class['postgresql::server::service'],
          before  => Class['postgresql::server::reload'],
        }
      }
    }
  }

  case $ensure {
    /present|absent/: {
      postgresql_conf { $name:
        ensure  => $ensure,
        target  => $target,
        value   => $value,
        require => Class['postgresql::server::initdb'],
      }
    }

    default: {
      fail("Unknown value for ensure '${ensure}'.")
    }
  }
}
