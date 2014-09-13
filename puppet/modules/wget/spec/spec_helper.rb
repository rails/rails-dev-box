require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.mock_framework = :mocha
  c.default_facts = {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux'
  }
  c.treat_symbols_as_metadata_keys_with_true_values = true

  c.before(:each) do
    # work around https://tickets.puppetlabs.com/browse/PUP-1547
    # ensure that there's at least one provider available by emulating that any command exists
    require 'puppet/confine/exists'
    Puppet::Confine::Exists.any_instance.stubs(:which => '')
    # avoid "Only root can execute commands as other users"
    Puppet.features.stubs(:root? => true)

    Puppet::Util::Log.level = :warning
    Puppet::Util::Log.newdestination(:console)
  end
end

shared_examples :compile, :compile => true do
  it { should compile.with_all_deps }
end
