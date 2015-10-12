require 'baton/observer'

module Baton
  class Consumer
    include Baton::Observer
    include Baton::Logging

    attr_accessor :consumer_name, :server, :consumer_manager

    # Public: Initialize a Consumer.
    #
    # consumer_name - A String naming the consumer.
    # server - An instance of Baton::Server.
    def initialize(consumer_name, server)
      @consumer_name, @server = consumer_name, server
    end

    # Public: Defines the routing key for the consumer. Messages with the
    # defined routing queue will be consumed by this consumer.
    #
    # Examples
    #
    #   routing_key
    #   # => "central-apu.production"
    #
    # Returns the routing key.
    def routing_key
      "#{consumer_name}.#{server.environment}"
    end

    # Public: Method that wraps a block and notifies when errors occur.
    #
    # Examples
    #
    #   exception_notifier do
    #     <your code>
    #   end
    #
    # Returns nothing.
    def exception_notifier
      yield
    rescue Exception => e
      notify_error(e.class, e.message)
    end

    # Public: Method that decodes a json message and passes it to process_message
    # to be processed.
    #
    # payload  - A message in json format
    #
    # Examples
    #
    #   handle_message("{\"message\":\"a message\",\"type\":\"a type\"}")
    #
    # Returns nothing.
    def handle_message(payload)
      exception_notifier do
        message = JSON.load(payload)
        process_message(message)
      end
    end

    # Public: Method that will be called when handle_message receives a message.
    # It should be implemented by baton-like gems and it should add logic to 
    # process messages.
    #
    # message  - A message in ruby-format
    #
    # Examples
    #
    #   process_message({"type" => "current"})
    #
    # Returns Output depends on the implementation.
    def process_message(message)
    end

    # Public: Method that provides an hash of attributes, if they are needed.
    #
    # Examples
    #
    #   attributes
    #   # => {type: "pong"}.merge(server.attributes)
    #
    # Returns Output depends on the implementation.
    def attributes
      {}
    end

  end
end
