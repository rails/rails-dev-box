require 'spec_helper_system'

describe 'wget' do
  before(:all) do
    puppet_apply(%Q(
      class { 'wget': }
    )).exit_code.should be_zero
  end

  before do
    shell "rm -f /tmp/index*"
  end

  it 'should be idempotent' do
    pp = %Q(
      wget::fetch { "download Google's index":
        source      => 'http://www.google.com/index.html',
        destination => '/tmp/index.html',
        timeout     => 0,
        verbose     => false,
      }
    )
    expect(puppet_apply(pp).exit_code).to eq(2)
    expect(puppet_apply(pp).exit_code).to be_zero
  end

  context 'when running as user' do
    let(:pp) { %Q(
      wget::fetch { 'download Google index':
        source      => 'http://www.google.com/index.html',
        destination => '/tmp/index-vagrant.html',
        timeout     => 0,
        verbose     => false,
      }
    ) }
    subject { shell "cat << EOF | su - vagrant -c 'puppet apply --verbose --modulepath=/etc/puppet/modules'\n#{pp}" }
    its(:exit_code) { should be_zero }
    its(:stdout) { should =~ %r{Wget::Fetch\[download Google index\].*returns: executed successfully} }
  end

end
