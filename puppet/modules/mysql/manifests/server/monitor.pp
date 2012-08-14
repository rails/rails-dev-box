class mysql::server::monitor (
  $mysql_monitor_username,
  $mysql_monitor_password,
  $mysql_monitor_hostname
) {

  Class['mysql::server'] -> Class['mysql::server::monitor']

  database_user{ "${mysql_monitor_username}@${mysql_monitor_hostname}":
    password_hash => mysql_password($mysql_monitor_password),
    ensure        => present,
  }

  database_grant { "${mysql_monitor_username}@${mysql_monitor_hostname}":
    privileges => [ 'process_priv', 'super_priv' ],
    require    => Mysql_user["${mysql_monitor_username}@${mysql_monitor_hostname}"],
  }

}
