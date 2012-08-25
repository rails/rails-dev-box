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


  package { 'libmysqlclient15-dev':
    ensure => installed
  }
}
class { 'install_mysql': }

class install_postgres {
  class { 'postgresql': }

  class { 'postgresql::server': }

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

class install_rbenv {
  $user = 'vagrant'
  $home = "/home/${user}"

  rbenv::install { 'vagrant':
    group => $user
    home  => $home
  }

  rbenv::compile { "1.9.3-p370":
    user => $user,
    home => $home,
  }

  exec
}
class { 'install_rbenv': }

class { 'memcached': }
