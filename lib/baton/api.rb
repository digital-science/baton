require "baton"
require "bunny"
require "json"

module Baton
  class API

    # Public: Method that publishes a message using Bunny to an exchange.
    #
    # message - a json object containing the message
    # key - the routing key used to forward the message to the right queue(s)
    #
    # Examples
    #
    #   publish("{\"message\":\"a message\",\"type\":\"a type\"}", "server.production")
    #
    # Returns nothing.
    def self.publish(message, key)
      b = Bunny.new(Baton.configuration.connection_opts)
      b.start
      e = b.exchange(Baton.configuration.exchange, :auto_delete => false)
      e.publish(message, :key => key, :mandatory => true)
      b.stop
    end

  end
end
