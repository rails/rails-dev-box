define rbenv::client(
  $user,
  $home,
  $ruby,
  $owner,
  $source,
) {
  if ! defined(Exec["rbenv::compile ${owner} ${ruby}"]) {
    fail("Ruby version ${ruby} is not compiled for ${owner}")
  }

  file {"${user}/.rbenv":
    ensure => link,
    path   => "${home}/.rbenv",
    target => "${source}/.rbenv",
  }

  file {"${user}/.bashrc":
    ensure => link,
    path   => "${home}/.bashrc",
    target => "${source}/.bashrc",
  }

  file {"${user}/.gemrc":
    ensure => link,
    path   => "${home}/.gemrc",
    target => "${source}/.gemrc",
  }

  file {"${user}/.rbenv-version":
    ensure  => present,
    path    => "${home}/.rbenv-version",
    content => "$ruby\n",
  }

  file {"${user}/bin":
    ensure => directory,
    path   => "${home}/bin",
    owner  => $user,
  }

  file {"${user}/bin/rbenv":
    ensure => link,
    path   => "${home}/bin/rbenv",
    target => "${source}/.rbenv/bin/rbenv",
  }
}
