define rbenv::plugin::rbenvvars(
  $user   = $title,
  $source = 'git://github.com/sstephenson/rbenv-vars.git',
  $group  = $user,
  $home   = '',
  $root   = ''
) {
  rbenv::plugin { "rbenv::plugin::rbenvvars::${user}":
    user        => $user,
    source      => $source,
    plugin_name => 'rbenv-vars',
    group       => $group,
    home        => $home,
    root        => $root
  }
}
