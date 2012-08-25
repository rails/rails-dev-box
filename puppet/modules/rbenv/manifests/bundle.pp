define rbenv::bundle(
  $home,
  $user,
  $group   = $user,
  $content = '',
  $gems    = '',
) {

  if ( $gems ) {
    $gemfile = template('rbenv/Gemfile.erb')
  } elsif ( $content ) {
    $gemfile = $content
  } else {
    fail('bundle requires either a gem list or a Gemfile')
  }

  file {"${user}/Gemfile":
    ensure  => present,
    path    => "${home}/Gemfile",
    owner   => $user,
    group   => $group,
    content => $gemfile,
    backup  => false,
    require => Rbenv::Client[$user],
  }

  exec {"${user} bundle":
    command   => "bundle --binstubs=${home}/bin --path=${home}/.bundle",
    cwd       => $home,
    user      => $user,
    group     => $group,
    path      => "${home}/bin:${home}/.rbenv/shims:/bin:/usr/bin",
    creates   => "${home}/Gemfile.lock",
    subscribe => File["${user}/Gemfile"],
  }
}
