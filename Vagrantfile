# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure('2') do |config|
  # FIXME: When upgrading to a future version of Ubuntu check if the workaround
  # near the top of bootstrap.sh is still needed. If not, please delete it.
  config.vm.box      = 'ubuntu/artful64' # 17.10
  config.vm.hostname = 'rails-dev-box'

  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.vm.provision :shell, path: 'bootstrap.sh', keep_color: true

  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 2
  end
end
