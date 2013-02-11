require 'simplecov'
SimpleCov.start do
  add_filter "/spec"
end
require 'rubygems'
require 'bundler'
Bundler.setup
require 'fakefs/spec_helpers'
require "moqueue"
require "rspec/expectations"
require 'webmock/rspec'
require "baton/logging"
require 'json'
require 'pry'

WebMock.disable_net_connect!

FileUtils.mkdir_p 'log' unless File.exists?('log')
Baton::Logging.logger = "log/test.log"
