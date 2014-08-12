require "bundler/gem_tasks"
require "rspec/core/rake_task"

# Default :spec task
RSpec::Core::RakeTask.new(:spec)
# .rspec is used for options.
# Different options for 'rake spec' can be configured using the below version.
#RSpec::Core::RakeTask.new do |task|
#  task.rspec_opts = ['--color', '--format', 'progress']
#end

task :default => :spec