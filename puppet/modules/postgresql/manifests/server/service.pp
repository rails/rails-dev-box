# PRIVATE CLASS: do not call directly
class postgresql::server::service {
  $ensure           = $postgresql::server::ensure
  $service_ensure   = $postgresql::server::service_ensure
  $service_name     = $postgresql::server::service_name
  $service_provider = $postgresql::server::service_provider
  $service_status   = $postgresql::server::service_status
  $user             = $postgresql::server::user
  $port             = $postgresql::server::port
  $default_database = $postgresql::server::default_database

  if $service_ensure {
    $real_service_ensure = $service_ensure
  } else {
    $real_service_ensure = $ensure ? {
      present => 'running',
      absent  => 'stopped',
      default => $ensure
    }
  }

  $service_enable = $ensure ? {
    present => true,
    absent  => false,
    default => $ensure
  }

  anchor { 'postgresql::server::service::begin': }

  service { 'postgresqld':
    ensure    => $real_service_ensure,
    name      => $service_name,
    enable    => $service_enable,
    provider  => $service_provider,
    hasstatus => true,
    status    => $service_status,
  }

  if $real_service_ensure == 'running' {
    # This blocks the class before continuing if chained correctly, making
    # sure the service really is 'up' before continuing.
    #
    # Without it, we may continue doing more work before the database is
    # prepared leading to a nasty race condition.
    postgresql::validate_db_connection { 'validate_service_is_running':
      run_as          => $user,
      database_name   => $default_database,
      database_port   => $port,
      sleep           => 1,
      tries           => 60,
      create_db_first => false,
      require         => Service['postgresqld'],
      before          => Anchor['postgresql::server::service::end']
    }
  }

  anchor { 'postgresql::server::service::end': }
}
