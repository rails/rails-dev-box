require 'spec_helper'

describe 'redis::instance', :type => 'define' do
  let(:title) { 'redis-instance' }

  let :facts do
    {
      :osfamily  => 'RedHat'
    }
  end # let

  context "On Debian systems with default parameters" do
    it do
      should contain_file('redis_port_6379.conf').with_content(/^port 6379$/)
      should contain_file('redis_port_6379.conf').with_content(/^save 900 1$/)
      should contain_file('redis_port_6379.conf').with_content(/^save 300 10$/)
      should contain_file('redis_port_6379.conf').with_content(/^save 60 10000$/)
    end # it
  end # context

  context "On Debian systems with no password parameter" do
    let :params do
      {
        :redis_password => false
      }
    end # let

    it do
      should contain_file('redis_port_6379.conf').without_content(/^requirepass/)
    end # it
  end # context

  context "On Debian systems with password parameter" do
    let :params do
      {
        :redis_port     => '6900',
        :redis_password => 'ThisIsAReallyBigSecret'
      }
    end # let

    it do
      should compile.with_all_deps

      should contain_file('redis_port_6900.conf').with_content(/^requirepass ThisIsAReallyBigSecret/)
      should contain_file('redis-init-6900').with_content(/^CLIEXEC="[\w\/]+redis-cli -h \$REDIS_BIND_ADDRESS -p \$REDIS_PORT -a ThisIsAReallyBigSecret/)
    end # it
  end # context

  context "With a non-default port parameter" do
    let :params do
      {
        :redis_port => '6900'
      }
    end # let

    it do
      should compile.with_all_deps

      should contain_file('redis_port_6900.conf').with_content(/^port 6900$/)
      should contain_file('redis_port_6900.conf').with_content(/^pidfile \/var\/run\/redis_6900\.pid$/)
      should contain_file('redis_port_6900.conf').with_content(/^logfile \/var\/log\/redis_6900\.log$/)
      should contain_file('redis_port_6900.conf').with_content(/^dir \/var\/lib\/redis\/6900$/)
      should contain_file('redis-init-6900').with_content(/^REDIS_PORT="6900"$/)
    end # it
  end # context

  context "With a non default bind address" do
    let :params do
      {
        :redis_port => '6900',
        :redis_bind_address => '10.1.2.3'
      }
    end # let

    it do
      should compile.with_all_deps

      should contain_file('redis_port_6900.conf').with_content(/^bind 10\.1\.2\.3$/)
      should contain_file('redis-init-6900').with_content(/^REDIS_BIND_ADDRESS="10.1.2.3"$/)
    end # it
  end # context

  context "On Debian systems with no saves" do
    let :params do
      {
        :redis_port  => '6380',
        :redis_saves => false
      }
    end

    it do
      should contain_file('redis_port_6380.conf').with_ensure('present')
      should contain_file('redis_port_6380.conf').without_content(/^requirepass/)
      should contain_file('redis_port_6380.conf').without_content(/^save 900 1$/)
    end # it
  end # context

  context "On Debian systems with saves set to \['save 3600 1000000'\]" do
    let :params do
      {
        :redis_port  => '7000',
        :redis_saves => ['save 3600 1000000', 'save 17 42']
      }
    end # let

    it do
      should contain_file('redis_port_7000.conf').with_ensure('present')
      should contain_file('redis_port_7000.conf').without_content(/^requirepass/)
      should contain_file('redis_port_7000.conf').with_content(/^port 7000$/)
      should contain_file('redis_port_7000.conf').with_content(/^save 3600 1000000$/)
      should contain_file('redis_port_7000.conf').with_content(/^save 17 42$/)
      should contain_file('redis_port_7000.conf').without_content(/^save 900 1$/)
    end # it
  end # context
end # describe
