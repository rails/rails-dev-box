# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure('2') do |config|
  config.vm.box      = 'ubuntu/zesty64' # 17.04
  config.vm.hostname = 'rails-dev-box'

  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  config.vm.provision :shell, path: 'bootstrap.sh', keep_color: true

  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 2
  end
end
