#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:test)
task :test => :spec

task :console do
  sh "irb -rubygems -I lib -r baton.rb"
end
