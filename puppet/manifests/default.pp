$ar_databases = ['activerecord_unittest', 'activerecord_unittest2']

stage { 'ubuntu_packages_setup':
  before => Stage['main']
}

class apt_get_update1 {
  exec { 'apt_get_update_exec1':
    command => '/usr/bin/apt-get -y update',
    user    => 'root'
  }
}
class { 'apt_get_update1':
  stage => ubuntu_packages_setup
}

class install_python_software_properties {
  package { 'python-software-properties':
    ensure => installed
  }
}
class { 'install_python_software_properties':
  stage   => ubuntu_packages_setup,
  require => Class['apt_get_update1']
}

class apt_add_repository {
  exec { '/usr/bin/apt-add-repository ppa:brightbox/ruby-ng':
    user => 'root'
  }
}
class { 'apt_add_repository':
  stage   => ubuntu_packages_setup,
  require => Class['install_python_software_properties']
}

class apt_get_update2 {
  exec { 'apt_get_update_exec2':
    command => '/usr/bin/apt-get -y update',
    user    => 'root'
  }  
}
class { 'apt_get_update2':
  stage   => ubuntu_packages_setup,
  require => Class['apt_add_repository']
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
  if !defined(Package['build-essential']) {
    package { 'build-essential':
      ensure => installed
    }
  }

  if !defined(Package['git-core']) {
    package { 'git-core':
      ensure => installed
    }
  }
}
class { 'install_core_packages': }

class install_ruby {
  package { ['ruby', 'rubygems', 'ruby-switch', 'ruby1.9.3']:
    ensure => installed
  }

  exec { '/usr/bin/ruby-switch --set ruby1.9.1':
    user    => 'root',
    require => [
      Package['ruby-switch'],
      Package['ruby'],
      Package['ruby1.9.3']
    ]
  }

  exec { '/usr/bin/gem1.8 install bundler --no-rdoc --no-ri':
    unless  => '/usr/bin/gem1.8 list | grep bundler',
    user    => 'root',
    require => Package['rubygems']
  }

  exec { '/usr/bin/gem1.9.3 install bundler --no-rdoc --no-ri':
    unless  => '/usr/bin/gem1.9.3 list | grep bundler',
    user    => 'root',
    require => Package['ruby1.9.3']
  }
}
class { 'install_ruby': }

class install_nokogiri_dependencies {
  package { ['libxml2', 'libxml2-dev', 'libxslt1-dev']:
    ensure => installed
  }
}
class { 'install_nokogiri_dependencies': }

class install_execjs_runtime {
  package { 'nodejs':
    ensure => installed
  }
}
class { 'install_execjs_runtime': }

class { 'memcached': }
