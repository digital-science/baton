#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"

task :default => [:test]

RSpec::Core::RakeTask.new(:test)

desc "Run RSpec tests"
task :test => :spec

desc "Run a console with baton lib loaded"
task :console do
  sh "irb -rubygems -I lib -r baton.rb"
end
