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

SimpleCov.start do
  add_filter "/spec/"
end


def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(*segments)
  fakefs_status = (defined? FakeFS).nil? ? false : FakeFS.activated?
  FakeFS.deactivate! if fakefs_status
  fixture = File.read(File.join(fixture_path, *segments))
  FakeFS.activate! if fakefs_status
  fixture
end

def fixture_to_fakefs(name, filepath)
  raise "FakeFS required but not installed or activated" unless !(defined? FakeFS).nil? && FakeFS.activated?

  fixture_content = fixture(name)
  FileUtils.mkdir_p(File.dirname(filepath))
  File.open(filepath, "w") { |f| f.write(fixture_content) }
end

require 'hostsfile'