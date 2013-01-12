class rbenv {
  file { "/home/vagrant/.bash_profile":
    source  => "puppet:///modules/rbenv/.bash_profile",
    ensure => present;
  }

  package {
    [
     'bison',
     'autoconf',
     'git'
    ] :
      ensure => installed;
  }

  exec { "ruby-build":
    path    => "/usr/bin",
    command => "git clone git://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build",
    user    => "vagrant",
    unless  => "test -d /home/vagrant/.rbenv/plugins/ruby-build",
    require => Exec["rbenv"];
  }

  exec { "rbenv":
    path    => "/usr/bin",
    command => "git clone git://github.com/sstephenson/rbenv.git /home/vagrant/.rbenv",
    user    => "vagrant",
    unless  => "test -d /home/vagrant/.rbenv",
    require => [
      Package[
        'bison',
        'autoconf',
        'git'
      ],
    ];
  }
}
