source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  gem 'rake', '10.1.1'
  gem 'puppetlabs_spec_helper', :require => false
  gem 'rspec-puppet', '~> 1.0'
  gem 'rspec', '~> 2.11',       :require => false
  gem 'puppet-lint', '~> 0.3.2'
  gem 'beaker-rspec',           :require => false
  gem 'serverspec',             :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
