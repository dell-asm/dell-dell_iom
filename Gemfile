source 'https://rubygems.org'

gem 'dell-force10', :git => 'https://github.com/dell-asm/dell-force10.git'

group :development, :test do
  gem 'rake'
  gem 'rspec'
  gem 'puppetlabs_spec_helper'
  gem 'json_pure', '2.0.1'
  if puppetversion = ENV['PUPPET_GEM_VERSION']
    gem 'puppet', puppetversion
  else
    gem 'puppet', '3.4.2'
  end
end
