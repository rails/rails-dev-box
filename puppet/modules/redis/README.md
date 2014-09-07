redis puppet module
===================

[![Build Status](https://secure.travis-ci.org/thomasvandoren/puppet-redis.png)](http://travis-ci.org/thomasvandoren/puppet-redis)

Install and configure redis.

Usage
-----
Installs redis server and client with reasonable defaults.

```puppet
include redis
```

Installs redis server and client with version 2.6.5.

```puppet
class { 'redis':
  version => '2.6.5',
}
```

Installs version 2.4.17, listens on default port 6379 with default settings.
Sets up 2nd instance on port 6900, binds to address 10.1.2.3 (instead of all 
available interfaces), sets max memory to 1 gigabyte, and sets a password from 
hiera.

```puppet
class { 'redis':
  version            => '2.4.17',
}
redis::instance { 'redis-6900':
  redis_port         => '6900',
  redis_bind_address => '10.1.2.3',
  redis_password     => hiera('redis_password'),
  redis_max_memory   => '1gb',
}
```

Development
-----------

To run the linter and spec tests locally:

```bash
bundle install --gemfile .gemfile
rake lint
rake spec
```

Authors
-------
Thomas Van Doren

License
-------
BSD
