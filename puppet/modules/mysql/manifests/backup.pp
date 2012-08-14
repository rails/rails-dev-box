# Class: mysql::backup
#
# This module handles ...
#
# Parameters:
#   [*backupuser*]     - The name of the mysql backup user.
#   [*backuppassword*] - The password of the mysql backup user.
#   [*backupdir*]      - The target directory of the mysqldump.
#
# Actions:
#   GRANT SELECT, RELOAD, LOCK TABLES ON *.* TO 'user'@'localhost'
#    IDENTIFIED BY 'password';
#
# Requires:
#   Class['mysql::config']
#
# Sample Usage:
#   class { 'mysql::backup':
#     backupuser     => 'myuser',
#     backuppassword => 'mypassword',
#     backupdir      => '/tmp/backups',
#   }
#
class mysql::backup (
  $backupuser,
  $backuppassword,
  $backupdir,
  $ensure = 'present'
) {

  database_user { "${backupuser}@localhost":
    ensure        => $ensure,
    password_hash => mysql_password($backuppassword),
    provider      => 'mysql',
    require       => Class['mysql::config'],
  }

  database_grant { "${backupuser}@localhost":
    privileges => [ 'Select_priv', 'Reload_priv', 'Lock_tables_priv' ],
    require    => Database_user["${backupuser}@localhost"],
  }

  cron { 'mysql-backup':
    ensure  => $ensure,
    command => '/usr/local/sbin/mysqlbackup.sh',
    user    => 'root',
    hour    => 23,
    minute  => 5,
    require => File['mysqlbackup.sh'],
  }

  file { 'mysqlbackup.sh':
    ensure  => $ensure,
    path    => '/usr/local/sbin/mysqlbackup.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('mysql/mysqlbackup.sh.erb'),
  }

  file { 'mysqlbackupdir':
    ensure => 'directory',
    path   => $backupdir,
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
  }
}
