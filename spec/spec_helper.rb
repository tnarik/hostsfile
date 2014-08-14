require 'bundler/setup'
Bundler.setup

require 'simplecov'
require 'simplecov-console'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'hostsfile'