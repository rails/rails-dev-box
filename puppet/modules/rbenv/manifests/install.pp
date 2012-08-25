define rbenv::install(
  $user  = $title,
  $group = $user,
  $home  = '',
  $root  = '',
) {

  # Workaround http://projects.puppetlabs.com/issues/9848
  $home_path = $home ? { '' => "/home/${user}", default => $home }
  $root_path = $root ? { '' => "${home_path}/.rbenv", default => $root }

  $rbenvrc = "${home_path}/.rbenvrc"
  $bashrc  = "${home_path}/.bashrc"

  if ! defined( Class['rbenv-dependencies'] ) {
    require rbenv::dependencies
  }

  exec { "rbenv::checkout ${user}":
    command => "git clone git://github.com/sstephenson/rbenv.git ${root_path}",
    user    => $user,
    group   => $group,
    creates => $root_path,
    path    => ['/usr/bin', '/usr/sbin'],
    timeout => 100,
    require => Package['git'],
  }

  file { "rbenv::rbenvrc ${user}":
    path    => $rbenvrc,
    owner   => $user,
    group   => $group,
    content => template('rbenv/dot.rbenvrc.erb'),
  }

  exec { "rbenv::bashrc ${user}":
    command => "echo 'source ${rbenvrc}' >> ${bashrc}",
    user    => $user,
    group   => $group,
    unless  => "grep -q rbenvrc ${bashrc}",
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
    require => File["rbenv::rbenvrc ${user}"],
  }
}
