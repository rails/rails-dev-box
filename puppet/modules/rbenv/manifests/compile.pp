# The following part compiles and installs the chosen ruby version,
# using the "ruby-build" rbenv plugin.
#
define rbenv::compile(
  $user,
  $ruby   = $title,
  $group  = $user,
  $home   = '',
  $root   = '',
  $source = '',
  $global = false,
) {

  # Workaround http://projects.puppetlabs.com/issues/9848
  $home_path = $home ? { '' => "/home/${user}", default => $home }
  $root_path = $root ? { '' => "${home_path}/.rbenv", default => $root }

  $bin         = "${root_path}/bin"
  $shims       = "${root_path}/shims"
  $versions    = "${root_path}/versions"
  $global_path = "${root_path}/version"
  $path        = [ $shims, $bin, '/bin', '/usr/bin' ]

  if ! defined( Class['rbenv-dependencies'] ) {
    require rbenv::dependencies
  }

  # If no ruby-build has been specified and the default resource hasn't been
  # parsed
  $custom_or_default = Rbenv::Plugin["rbenv::plugin::rubybuild::${user}"]
  $default           = Rbenv::Plugin::Rubybuild["rbenv::rubybuild::${user}"]
  if ! defined($custom_or_default) and ! defined($default) {
    debug("No ruby-build found for ${user}, going to add the default one")
    rbenv::plugin::rubybuild { "rbenv::rubybuild::${user}":
      user   => $user,
      group  => $group,
      home   => $home,
      root   => $root
    }
  }

  if $source {
    rbenv::definition { "rbenv::definition ${user} ${ruby}":
      user    => $user,
      group   => $group,
      source  => $source,
      ruby    => $ruby,
      home    => $home,
      root    => $root,
      require => Rbenv::Plugin["rbenv::plugin::rubybuild::${user}"],
      before  => Exec["rbenv::compile ${user} ${ruby}"]
    }
  }

  # Set Timeout to disabled cause we need a lot of time to compile.
  # Use HOME variable and define PATH correctly.
  exec { "rbenv::compile ${user} ${ruby}":
    command     => "rbenv install ${ruby}; touch ${root_path}/.rehash",
    timeout     => 0,
    user        => $user,
    group       => $group,
    cwd         => $home_path,
    environment => [ "HOME=${home_path}" ],
    creates     => "${versions}/${ruby}",
    path        => $path,
    require     => Rbenv::Plugin["rbenv::plugin::rubybuild::${user}"],
    before      => Exec["rbenv::rehash ${user}"],
  }

  if ! defined( Exec["rbenv::rehash ${user}"] ) {
    exec { "rbenv::rehash ${user}":
      command     => "rbenv rehash; rm -f ${root_path}/.rehash",
      user        => $user,
      group       => $group,
      cwd         => $home_path,
      onlyif      => "[ -e '${root_path}/.rehash' ]",
      environment => [ "HOME=${home_path}" ],
      path        => $path,
    }
  }

  # Install bundler
  #
  gem {"rbenv::bundler ${user} ${ruby}":
    ensure => present,
    gem    => 'bundler',
    user   => $user,
    ruby   => $ruby,
    home   => $home_path,
    root   => $root_path,
  }

  # Set default global ruby version for rbenv, if requested
  #
  if $global {
    file { "rbenv::global ${user}":
      path    => $global_path,
      content => "$ruby\n",
      owner   => $user,
      group   => $group,
    }
  }
}
