Vagrant::Config.run do |config|
  config.vm.box       = 'brotodevbox'
  config.vm.box_url   = 'http://files.vagrantup.com/precise32.box'
  config.vm.host_name = 'brotodevbox'

  config.vm.forward_port 3000, 3000
  config.vm.forward_port 4321, 4321

  config.vm.share_folder 'code', "/home/vagrant/code", "~/Code"

  config.vm.provision :puppet,
    :manifests_path => 'puppet/manifests',
    :module_path    => 'puppet/modules'
end
