# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hostsfile/version'

Gem::Specification.new do |spec|
  spec.name          = "hostsfile"
  spec.version       = Hostsfile::VERSION
  spec.authors       = ["Tnarik Innael"]
  spec.email         = ["tnarik@lecafeautomatique.co.uk"]
  spec.summary       = %q{code from the hostsfile cookbook to allow reusability}
  spec.description   = %q{code from the hostsfile cookbook to allow reusability}
  spec.homepage      = "https://github.com/tnarik/hostsfile"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # development dependencies  
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  # development dependencies (testing)
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "fakefs"

  # development dependencies (coverage)
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-console'
  
  # development dependencies (notifier), controlled by .guard.rb
  spec.add_development_dependency "terminal-notifier-guard"
  spec.add_development_dependency "ruby_gntp" # Pre OS X 10.8
end
