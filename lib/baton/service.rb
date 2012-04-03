require "baton"
require "amqp"
require "eventmachine"
require "em-http-request"
require "json"
require "baton/channel"
require "baton/server"
require "baton/consumer_manager"

module Baton
  class Service
    include Baton::Logging

    attr_accessor :server, :channel

    # Public: Initialize a Service. Sets up a new server for this service.
    def initialize
      @server = Baton::Server.new
    end

    # Public: Method that starts the service.
    #
    # Returns nothing.
    def run
      logger.info "Starting Baton v#{Baton::VERSION}"
      EM.run do
        @channel = Baton::Channel.new
        setup_consumers
      end
    end

    # Public: Method that allows implementations to setup new consumers
    # depending on their needs. An example would be add a deploy consumer
    # which will listen to deploy messages. For each consumer, add_consumer
    # should be called to attach the consumers to the AMQP channel.
    #
    # Returns Output depends on the implementation.
    def setup_consumers
    end

    # Public: Adds a given consumer to the AMQP channel.
    #
    # consumer - An instance of Baton::Consumer.
    #
    # Examples
    #
    #   add_consumer(Baton::DeployConsumer.new("consumer_name", Baton::Server.new))
    #
    # Returns nothing..
    def add_consumer(consumer)
      channel.add_consumer(consumer)
    end

  end
end
