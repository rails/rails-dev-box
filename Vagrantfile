Vagrant::Config.run do |config|
  # Run:
  #
  #   vagrant box add precise32 http://files.vagrantup.com/precise32.box
  #
  # if needed (you need that only once).
  config.vm.box = 'precise32'

  config.vm.forward_port 3000, 3000

  config.vm.provision :puppet,
    :manifests_path => 'puppet/manifests',
    :module_path    => 'puppet/modules'
end
