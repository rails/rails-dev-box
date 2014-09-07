require 'spec_helper'

describe 'wget::authfetch' do
  let(:title) { 'authtest' }
  let(:params) {{
    :source      => 'http://localhost/source',
    :destination => destination,
    :user        => 'myuser',
    :password    => 'mypassword',
  }}

  let(:destination) { "/tmp/dest" }

  context "with default params", :compile do
    it { should contain_exec('wget-authtest').with({
      'command'     => "wget --no-verbose --user=myuser --output-document='#{destination}' 'http://localhost/source'",
      'environment' => "WGETRC=#{destination}.wgetrc"
      })
    }
    it { should contain_file("#{destination}.wgetrc").with_content('password=mypassword') }
  end

  context "with user", :compile do
    let(:params) { super().merge({
      :execuser => 'testuser',
    })}

    it { should contain_exec('wget-authtest').with({
      'command' => "wget --no-verbose --user=myuser --output-document='#{destination}' 'http://localhost/source'",
      'user'    => 'testuser'
    }) }
  end
end
