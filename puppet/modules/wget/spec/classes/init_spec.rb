require 'spec_helper'

describe 'wget' do

  context 'no version specified', :compile do
    it { should contain_package('wget').with_ensure('present') }
  end

  context 'version is 1.2.3', :compile do
    let(:params) { {:version => '1.2.3'} }

    it { should contain_package('wget').with_ensure('1.2.3') }
  end

  context 'running on OS X', :compile do
    let(:facts) { {
      :operatingsystem => 'Darwin',
      :kernel => 'Darwin'
    } }

    it { should_not contain_package('wget') }
  end

  context 'running on FreeBSD', :compile do
    let(:facts) { {
      :operatingsystem => 'FreeBSD',
      :kernel => 'FreeBSD'
    } }

    it { should contain_package('ftp/wget') }
  end
end
