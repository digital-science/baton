require 'simplecov'
SimpleCov.start do
  add_filter "/spec"
end
require 'rubygems'
require 'bundler'
Bundler.setup
require 'fakefs/spec_helpers'
require "moqueue"
require 'webmock/rspec'
require "rspec/expectations"
require "baton/logging"
require 'json'

WebMock.disable_net_connect!

FileUtils.mkdir_p 'log' unless File.exists?('log')
Baton::Logging.logger = "log/test.log"
