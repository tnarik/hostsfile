# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hostsfile/version'

Gem::Specification.new do |gem|
  gem.name          = "hostsfile"
  gem.version       = Hostsfile::VERSION
  gem.authors       = ["tnarik"]
  gem.email         = ["tnarik@lecafeautomatique.co.uk"]
  gem.description   = %q{code from the hostsfile cookbook to allow reusability}
  gem.summary       = %q{code from the hostsfile cookbook to allow reusability}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
