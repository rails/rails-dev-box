require 'spec_helper'

describe 'apt_package_updates fact' do
  subject { Facter.fact(:apt_package_updates).value }
  after(:each) { Facter.clear }

  describe 'on Debian based distro missing update-notifier-common' do
    before { 
    Facter.fact(:osfamily).stubs(:value).returns 'Debian'
    File.stubs(:executable?).returns false
  }
  it { should == nil }
  end

  describe 'on Debian based distro' do
    before { 
    Facter.fact(:osfamily).stubs(:value).returns 'Debian'
    File.stubs(:executable?).returns true
    Facter::Util::Resolution.stubs(:exec).returns "puppet-common\nlinux-generic\nlinux-image-generic"
  }
  it {
    if Facter.version < '2.0.0'
      should == 'puppet-common,linux-generic,linux-image-generic'
    else
      should == ['puppet-common', 'linux-generic', 'linux-image-generic']
    end
  }
  end
end
