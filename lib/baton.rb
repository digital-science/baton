require "baton/configuration"
require "baton/version"
require "baton/logging"

module Baton
  def self.configuration
    @configuration ||= Baton::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end
end
