$ar_databases = ['activerecord_unittest', 'activerecord_unittest2']

# Make sure apt-get -y update runs before anything else.
stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { '/usr/bin/apt-get -y update':
    user => 'root'
  }
}
class { 'apt_get_update':
  stage => preinstall
}

class install_sqlite3 {
  package { 'sqlite3':
    ensure => installed;
  }

  package { 'libsqlite3-dev':
    ensure => installed;
  }
}
class { 'install_sqlite3': }

class install_mysql {
  class { 'mysql': }

  class { 'mysql::server':
    config_hash => { 'root_password' => '' }
  }

  database { $ar_databases:
    ensure  => present,
    charset => 'utf8',
    require => Class['mysql::server'] 
  }

  database_user { 'rails@localhost':
    ensure  => present,
    require => Class['mysql::server'] 
  }

  database_grant { ['rails@localhost/activerecord_unittest', 'rails@localhost/activerecord_unittest2']:
    privileges => ['all'],
    require    => Database_user['rails@localhost']
  }

  package { 'libmysqlclient15-dev':
    ensure => installed
  }
}
class { 'install_mysql': }

class install_postgres {
  class { 'postgresql': }

  class { 'postgresql::server': }

  pg_database { $ar_databases:
    ensure   => present,
    encoding => 'UTF8',
    require  => Class['postgresql::server']
  }

  pg_user { 'rails':
    ensure  => present,
    require => Class['postgresql::server'] 
  }

  pg_user { 'vagrant':
    ensure    => present,
    superuser => true,
    require   => Class['postgresql::server']
  }

  package { 'libpq-dev':
    ensure => installed
  }
}
class { 'install_postgres': }

class install_core_packages {
  package { ['build-essential', 'git-core']:
    ensure => installed
  }
}
class { 'install_core_packages': }

class install_ruby {
  package { 'ruby1.9.3':
    ensure => installed
  }

  exec { '/usr/bin/gem install bundler --no-rdoc --no-ri':
    unless  => '/usr/bin/gem list | grep bundler',
    user    => 'root',
    require => Package['ruby1.9.3']
  }

  exec { '/usr/bin/gem install therubyracer --no-rdoc --no-ri':
    unless  => '/usr/bin/gem list | grep therubyracer',
    user    => 'root',
    require => [Package['ruby1.9.3'], Package['build-essential']]
  }
}
class { 'install_ruby': }

class install_nokogiri_dependencies {
  package { ['libxml2', 'libxml2-dev', 'libxslt1-dev']:
    ensure => installed
  }
}
class { 'install_nokogiri_dependencies': }

class { 'memcached': }
