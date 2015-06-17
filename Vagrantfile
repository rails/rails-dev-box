# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure('2') do |config|
  config.vm.box      = 'ubuntu/trusty64'
  config.vm.hostname = 'rails-dev-box'

  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.vm.provision :shell, path: 'bootstrap.sh', keep_color: true

  ## uncomment below to fix "No internet from guest" issue http://bit.ly/1d1qUlh
  # config.vm.provider "virtualbox" do |v|
  #   v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  #   v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  # end
end
