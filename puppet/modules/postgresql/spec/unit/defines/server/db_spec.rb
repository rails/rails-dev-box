require 'spec_helper'

describe 'postgresql::server::db', :type => :define do
  let :facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
      :kernel => 'Linux',
      :concat_basedir => tmpfilename('contrib'),
      :id => 'root',
      :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end

  let :title do
    'test'
  end

  context 'without dbname param' do

    let :params do
      {
        :user => 'test',
        :password => 'test',
        :owner => 'tester',
      }
    end

    let :pre_condition do
      "class {'postgresql::server':}"
    end

    it { should contain_postgresql__server__db('test') }
    it { should contain_postgresql__server__database('test').with_owner('tester') }
    it { should contain_postgresql__server__role('test') }
    it { should contain_postgresql__server__database_grant('GRANT test - ALL - test') }

  end

  context 'dbname' do

    let :params do
      {
        :dbname => 'testtest',
        :user => 'test',
        :password => 'test',
        :owner => 'tester',
      }
    end

    let :pre_condition do
      "class {'postgresql::server':}"
    end

    it { should contain_postgresql__server__database('testtest') }
  end
end
