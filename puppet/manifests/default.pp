Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}

$ar_databases = ['activerecord_unittest', 'activerecord_unittest2']
$as_vagrant   = 'sudo -u vagrant -H bash -l -c'

# Make sure apt-get -y update runs before anything else.
stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { 'apt-get -y update':
    user   => 'root',
    unless => 'test -e /home/vagrant/.rvm'
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

class install_curl {
  package { 'curl':
    ensure => installed
  }
}
class { 'install_curl': }

class install_rvm {
  exec { "${as_vagrant} 'curl -L https://get.rvm.io | bash -s master'":
    creates => '/home/vagrant/.rvm',
    require => Class['install_curl']
  }
}
class { 'install_rvm': }

class install_ruby {
  exec { "${as_vagrant} 'rvm install 1.9.3 --latest-binary && rvm use 1.9.3 --default'":
    creates => '/home/vagrant/.rvm/bin/ruby',
    require => Class['install_rvm']
  }
}
class { 'install_ruby': }

class install_bundler {
  exec { "${as_vagrant} 'gem install bundler --no-rdoc --no-ri'":
    creates => '/home/vagrant/.rvm/bin/bundle',
    require => Class['install_ruby']
  }
}
class { 'install_bundler': }

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
