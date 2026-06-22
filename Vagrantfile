# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure('2') do |config|
  config.vm.box      = 'bento/ubuntu-26.04' # 26.04 LTS
  config.vm.hostname = 'rails-dev-box'

  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.vm.provision :shell, path: 'bootstrap.sh', keep_color: true

  config.vm.boot_timeout = 600

  config.vm.provider 'virtualbox' do |v|
    v.memory = ENV.fetch('RAILS_DEV_BOX_RAM', 2048).to_i
    v.cpus   = ENV.fetch('RAILS_DEV_BOX_CPUS', 2).to_i
  end

  # Reboot after updating VirtualBox Guest Additions to avoid the provision
  # appearing to hang at "Running kernel modules will not be replaced until
  # the system is restarted".
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_reboot = true
  end
end
