$ar_databases = ['activerecord_unittest', 'activerecord_unittest2']

Exec {
  path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
}

# --- SQLite -------------------------------------------------------------------

package { ['sqlite3', 'libsqlite3-dev']:
  ensure => installed
}

# --- MySQL --------------------------------------------------------------------

class install_mysql {
  class { 'mysql::client': }

  class { 'mysql::server':
    root_password => '',

    users => {
      'rails@localhost' => {
        ensure => 'present'
      }
    },

    grants => {
      'rails@localhost/*.*' => {
        privileges => ['ALL'],
        table      => '*.*',
        user       => 'rails@localhost',
      }
    }
  }

  mysql_database { $ar_databases:
    ensure  => present,
    charset => 'utf8',
    require => Class['mysql::server']
  }

  package { 'libmysqlclient-dev':
    ensure  => installed,
    require => [Class['mysql::client'], Class['mysql::server']]
  }
}
class { 'install_mysql': }

# --- PostgreSQL ---------------------------------------------------------------

class install_postgres {
  class { 'postgresql::globals':
    encoding => 'UTF8'
  }

  class { 'postgresql::server': }
  class { 'postgresql::server::contrib': }
  class { 'postgresql::lib::devel': }

  postgresql::server::role { 'rails': }

  postgresql::server::role { 'vagrant':
    superuser => true
  }

  postgresql::server::db { $ar_databases:
    user     => 'rails',
    password => ''
  }
}
class { 'install_postgres': }

# --- Memcached ----------------------------------------------------------------

package { 'memcached':
  ensure => installed
}

# --- Redis ----------------------------------------------------------------

package { 'redis-server':
  ensure => installed
}

# --- Rabbitmq ----------------------------------------------------------------

package { 'rabbitmq-server':
  ensure => installed
}

# --- Packages -----------------------------------------------------------------

package { 'curl':
  ensure => installed
}

package { 'build-essential':
  ensure => installed
}

package { 'git-core':
  ensure => installed
}

# Nokogiri dependencies.
package { ['libxml2', 'libxml2-dev', 'libxslt1-dev']:
  ensure => installed
}

# ExecJS runtime.
package { 'nodejs':
  ensure => installed
}

# --- Ruby ---------------------------------------------------------------------

include apt

apt::ppa { 'ppa:brightbox/ruby-ng': }

class { 'ruby':
  version            => '2.1',
  set_system_default => true,
  suppress_warnings  => true,
  require            => Apt::Ppa['ppa:brightbox/ruby-ng']
}

class { 'ruby::dev': }

# --- Locale -------------------------------------------------------------------

# Needed for docs generation.
exec { 'update-locale':
  command => 'update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8'
}
