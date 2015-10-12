require 'logger'

module Baton
  module Logging
    def logger
      Baton::Logging.logger
    end

    def self.logger
      STDOUT.sync = true
      @logger ||= Logger.new(STDOUT)
    end

    def self.logger=(out)
      @logger = Logger.new(out)
    end
  end
end
