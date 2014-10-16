require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'
require 'rspec-system-serverspec/helpers'
include Serverspec::Helper::RSpecSystem
include Serverspec::Helper::DetectOS
include RSpecSystemPuppet::Helpers

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Enable colour
  c.tty = true

  c.include RSpecSystemPuppet::Helpers

  # This is where we 'setup' the nodes before running our tests
  c.before :suite do
    # Install puppet
    puppet_install

    # Install modules and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'ruby')

    # Install the appropriate version of puppetlabs-stdlib
    case ENV['PUPPET_GEM_VERSION']
    when '~> 2.6.0'
      stdlib_ver = '2.5.1'
    when '~> 2.7.0'
      stdlib_ver = '3.2.0'
    else
      stdlib_ver = '4.1.0'
    end

    shell("puppet module install puppetlabs-stdlib --version #{stdlib_ver}")
  end
end