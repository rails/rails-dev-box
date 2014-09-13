#
class rabbitmq::install::rabbitmqadmin {

  $management_port = $rabbitmq::management_port
  $default_user = $rabbitmq::default_user
  $default_pass = $rabbitmq::default_pass

  staging::file { 'rabbitmqadmin':
    target  => '/var/lib/rabbitmq/rabbitmqadmin',
    source  => "http://${default_user}:${default_pass}@localhost:${management_port}/cli/rabbitmqadmin",
    require => [
      Class['rabbitmq::service'],
      Rabbitmq_plugin['rabbitmq_management']
    ],
  }

  file { '/usr/local/bin/rabbitmqadmin':
    owner   => 'root',
    group   => 'root',
    source  => '/var/lib/rabbitmq/rabbitmqadmin',
    mode    => '0755',
    require => Staging::File['rabbitmqadmin'],
  }

}
