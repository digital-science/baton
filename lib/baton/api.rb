require 'baton'
require 'bunny'
require 'json'

module Baton
  class API

    # Public: Method that publishes a message to an exchange.
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
      session = Bunny.new("amqps://#{Baton.configuration.connection_opts[:host]}:#{Baton.configuration.connection_opts[:port]}", Baton.configuration.connection_opts)
      session.start
      e = session.channel.exchange(Baton.configuration.exchange, :auto_delete => false)
      e.publish(message, :key => key, :mandatory => true)
      session.stop
    end

  end
end
