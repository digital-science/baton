require 'simplecov'
SimpleCov.start do
  add_filter "/spec"
end

require 'rubygems'
require 'bundler/setup'

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'
require 'baton'

require 'fakefs/spec_helpers'
require 'webmock/rspec'

WebMock.disable_net_connect!

FileUtils.mkdir_p 'log' unless File.exists?('log')
Baton::Logging.logger = "log/test.log"
