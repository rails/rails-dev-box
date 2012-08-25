class ohmyzsh {
  define custom_files($custom_files_repo = "git://github.com/brennovich/oh-my-zsh-custom.git")  {
    install_for_user { $user: }

    exec { "clone-custom-oh-my-zsh":
      path => "/bin:/usr/bin",
      cwd => "/home/$user/.oh-my-zsh/",
      user => $user,
      command => "git clone $custom_files_repo custom",
      creates => "/home/$user/.oh-my-zsh/custom/zshrc",
      require => [Package["git-core"], Exec["clone_oh_my_zsh"], Exec["remove-zsh-custom-dir"]],
    }

    exec { "remove-zsh-custom-dir":
      path => "/bin:/usr/bin",
      user => $user,
      command => "rm -rf /home/$user/.oh-my-zsh/custom",
      unless => "ls /home/$user/.oh-my-zsh/custom/.git",
      require => Install_for_user[$user],
    }

    exec { "update-custom-files":
      path => "/bin:/usr/bin",
      user => $user,
      cwd => "/home/$user/.oh-my-zsh/custom",
      command => "git reset HEAD --hard && git pull origin master",
      require => Exec["clone-custom-oh-my-zsh"],
    }

    file { "/home/$user/.zshrc":
      ensure => link,
      owner => $user,
      target => "/home/$user/.oh-my-zsh/custom/zshrc",
      require => Exec["clone-custom-oh-my-zsh"],
    }
  }

  define install_for_user($path = '/usr/bin/zsh') {

    if(!defined(Package["git-core"])) {
      package { "git-core":
        ensure => present,
      }
    }
    exec { "chsh -s $path $user":
      path => "/bin:/usr/bin",
      unless => "grep -E '^${name}.+:${$path}$' /etc/passwd",
      require => Package["zsh"]
    }

    package { "zsh":
      ensure => latest,
    }

    if(!defined(Package["curl"])) {
      package { "curl":
        ensure => present,
      }
    }

    exec { "copy-zshrc":
      path => "/bin:/usr/bin",
      cwd => "/home/$user",
      user => $user,
      command => "cp .oh-my-zsh/templates/zshrc.zsh-template .zshrc",
      unless => "ls .zshrc",
      require => Exec["clone_oh_my_zsh"],
    }

    exec { "clone_oh_my_zsh":
      path => "/bin:/usr/bin",
      cwd => "/home/$user",
      user => $user,
      command => "git clone https://github.com/robbyrussell/oh-my-zsh.git /home/$user/.oh-my-zsh",
      creates => "/home/$user/.oh-my-zsh",
      require => [Package["git-core"], Package["zsh"], Package["curl"]],
    }
  }

  custom_files { "git://github.com/brennovich/oh-my-zsh-custom.git": }
}
