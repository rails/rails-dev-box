require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rspec-system/rake_task'
require 'puppet-lint/tasks/puppet-lint'
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
# No idea why the next line is necessary, because it looks like everything is
# right, but we get errors anyway.
PuppetLint.configuration.send('disable_autoloader_layout')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp", "tests/**/*.pp"]

desc 'Check for puppet syntax errors.'
task :validate_puppet_syntax do
  if ENV['PUPPET_GEM_VERSION'] == '~> 2.6.0'
    puppet_parse_command = 'puppet --parseonly --ignoreimport'
  else
    puppet_parse_command = 'puppet parser validate --noop'
  end
  Dir['manifests/**/*.pp'].each do |path|
   sh "#{puppet_parse_command} #{path}"
  end
end

desc 'Check for ruby syntax errors.'
task :validate_ruby_syntax do
  ruby_parse_command = 'ruby -c'
  Dir['spec/**/*.rb'].each do |path|
   sh "#{ruby_parse_command} #{path}"
  end
end

desc 'Check for evil line endings.'
task :check_line_endings do
  Dir['spec/**/*.rb','manifests/**/*.pp'].each do |path|
   sh "file #{path}|grep -v CRLF"
  end
end
