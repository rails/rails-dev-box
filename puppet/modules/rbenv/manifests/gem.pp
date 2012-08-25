# Install a gem under rbenv for a certain user's ruby version.
# Requires rbenv::compile for the passed in user and ruby version
#
define rbenv::gem(
  $user,
  $ruby,
  $gem    = $title,
  $home   = '',
  $root   = '',
  $ensure = present,
) {

  # Workaround http://projects.puppetlabs.com/issues/9848
  $home_path = $home ? { '' => "/home/${user}", default => $home }
  $root_path = $root ? { '' => "${home_path}/.rbenv", default => $root }

  if ! defined( Exec["rbenv::compile ${user} ${ruby}"] ) {
    fail("Rbenv-Ruby ${ruby} for user ${user} not found in catalog")
  }

  rbenvgem {"${user}/${ruby}/${gem}":
    ensure  => $ensure,
    user    => $user,
    gemname => $gem,
    rbenv   => "${root_path}/versions/${ruby}",
    require => Exec["rbenv::compile ${user} ${ruby}"],
  }
}
