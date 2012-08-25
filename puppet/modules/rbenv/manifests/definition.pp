define rbenv::definition(
  $user,
  $source,
  $ruby  = $title,
  $group = $user,
  $home  = '',
  $root  = ''
) {

  $home_path = $home ? { '' => "/home/${user}",       default => $home }
  $root_path = $root ? { '' => "${home_path}/.rbenv", default => $root }

  $destination = "${root_path}/plugins/ruby-build/share/ruby-build/${ruby}"

  if $source =~ /^puppet:/ {
    file { "rbenv::definition-file ${user} ${ruby}":
      ensure  => file,
      source  => $source,
      group   => $group,
      path    => $destination,
      require => Exec["rbenv::plugin::checkout ${user} ruby-build"],
    }
  } elsif $source =~ /http(s)?:/ {
    exec { "rbenv::definition-file ${user} ${ruby}":
      command => "wget ${source} -O ${destination}",
      creates => $destination,
      user    => $user,
      require => Exec["rbenv::plugin::checkout ${user} ruby-build"],
    }
  }
}
