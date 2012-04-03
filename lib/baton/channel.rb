require "baton/consumer"
require "baton/logging"

module Baton
  class Channel
    include Baton::Logging

    attr_accessor :channel, :exchange_in, :exchange_out, :connection

    # Public: Initialize a Channel. It creates an AMQP  connection, a channel, 
    # an input and an output exchange and finally attaches the handle_channel_exception
    # callback to the on_error event on the channel.
    def initialize
      @connection   = AMQP.connect(Baton.configuration.connection_opts)
      @channel      = AMQP::Channel.new(@connection)
      @exchange_in  = channel.direct(Baton.configuration.exchange)
      @exchange_out = channel.direct(Baton.configuration.exchange_out)
      @connection.on_tcp_connection_loss(&method(:handle_tcp_failure))
      @channel.on_error(&method(:handle_channel_exception))
    end

    # Public: creates a consumer manager with a consumer attached and starts
    # listening to messages.
    #
    # consumer - An instance of Baton::Consumer. it will typically be a extension of
    # Baton::Consumer (e.g. Baton::DeployConsumer).
    #
    # Examples
    #
    #   add_consumer(consumer)
    #
    # Returns nothing.
    def add_consumer(consumer)
      Baton::ConsumerManager.new(consumer, channel, exchange_in, exchange_out).start
    end

    # Public: Callback to handle errors on an AMQP channel.
    #
    # channel - An AMQP channel
    # channel_close - 
    #
    # Returns nothing.
    #
    def handle_channel_exception(channel, channel_close)
      logger.error "Channel-level exception: code = #{channel_close.reply_code}, message = #{channel_close.reply_text}"
    end

    # Public: Callback to handle TCP connection loss
    #
    # connection - An AMQP Connection
    # settings - 
    #
    # Returns nothing.
    #
    def handle_tcp_failure(connection, settings)
      connection.reconnect(false, 10)
    end
  end
end
