require 'spec_helper'

describe 'apt_updates fact' do
  subject { Facter.fact(:apt_updates).value }
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
    Facter::Util::Resolution.stubs(:exec).returns '14;7'
  }
  it { should == 14 }
  end

end
