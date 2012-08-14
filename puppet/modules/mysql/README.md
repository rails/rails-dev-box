# Mysql module for Puppet

This module manages mysql on Linux (RedHat/Debian) distros. A native mysql provider implements database resource type to handle database, database user, and database permission.

## Description

This module uses the fact osfamily which is supported by Facter 1.6.1+. If you do not have facter 1.6.1 in your environment, the following manifests will provide the same functionality in site.pp (before declaring any node):

    if ! $::osfamily {
      case $::operatingsystem {
        'RedHat', 'Fedora', 'CentOS', 'Scientific', 'SLC', 'Ascendos', 'CloudLinux', 'PSBM', 'OracleLinux', 'OVS', 'OEL': {
          $osfamily = 'RedHat'
        }
        'ubuntu', 'debian': {
          $osfamily = 'Debian'
        }
        'SLES', 'SLED', 'OpenSuSE', 'SuSE': {
          $osfamily = 'Suse'
        }
        'Solaris', 'Nexenta': {
          $osfamily = 'Solaris'
        }
        default: {
          $osfamily = $::operatingsystem
        }
      }
    }

This module depends on creates_resources function which is introduced in Puppet 2.7. Users on puppet 2.6 can use the following module which provides this functionality:

[http://github.com/puppetlabs/puppetlabs-create_resources](http://github.com/puppetlabs/puppetlabs-create_resources)

This module is based on work by David Schmitt. The following contributor have contributed patches to this module (beyond Puppet Labs):

* Christian G. Warden
* Daniel Black
* Justin Ellison
* Lowe Schmidt
* Matthias Pigulla
* William Van Hevelingen
* Michael Arnold

## Usage

### mysql
Installs the mysql-client package.

    class { 'mysql': }

### mysql::java
Installs mysql bindings for java.

    class { 'mysql::java': }

### mysql::python
Installs mysql bindings for python.

    class { 'mysql::python': }

### mysql::ruby
Installs mysql bindings for ruby.

    class { 'mysql::ruby': }

### mysql::server
Installs mysql-server packages, configures my.cnf and starts mysqld service:

    class { 'mysql::server':
      config_hash => { 'root_password' => 'foo' }
    }

Database login information stored in `/root/.my.cnf`.

### mysql::db
Creates a database with a user and assign some privileges.

    mysql::db { 'mydb':
      user     => 'myuser',
      password => 'mypass',
      host     => 'localhost',
      grant    => ['all'],
    }

### mysql::backup
Installs a mysql backup script, cronjob, and priviledged backup user.

    class { 'mysql::backup':
      backupuser     => 'myuser',
      backuppassword => 'mypassword',
      backupdir      => '/tmp/backups',
    }

### Providers for database types:
MySQL provider supports puppet resources command:

    $ puppet resource database
    database { 'information_schema':
      ensure  => 'present',
      charset => 'utf8',
    }
    database { 'mysql':
      ensure  => 'present',
      charset => 'latin1',
    }

The custom resources can be used in any other manifests:

    database { 'mydb':
      charset => 'latin1',
    }

    database_user { 'bob@localhost':
      password_hash => mysql_password('foo')
    }

    database_grant { 'user@localhost/database':
      privileges => ['all'] ,
    }

A resource default can be specified to handle dependency:

    Database {
      require => Class['mysql::server'],
    }
