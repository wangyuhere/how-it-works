require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc 'Start a console'
task :console do
  require 'pry'
  $LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib"
  Pry.start
end

task c: :console
