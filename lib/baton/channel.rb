require "baton/consumer"
require "baton/logging"

module Baton
  class Channel
    include Baton::Logging

    attr_accessor :channel, :exchange_in, :exchange_out, :connection, :connection_options, :amqp_hosts

    # Public: Initialize a Channel. It creates an AMQP  connection, a channel,
    # an input and an output exchange and finally attaches the handle_channel_exception
    # callback to the on_error event on the channel.
    def initialize(service)

      @connection_options = Baton.configuration.connection_opts
      @amqp_hosts = Baton.configuration.amqp_host_list

      logger.info "Connecting to AMQP host: #{@connection_options[:host]}"

      @connection   = AMQP.connect(@connection_options)
      @channel      = AMQP::Channel.new(@connection)
      @channel.auto_recovery = true

      # Not everything needs an input exchange, default to the "" exchange if there isn't
      # one defined in the config (monitors for example)
      Baton.configuration.exchange = '' if Baton.configuration.exchange.nil?

      # Create the exchanges
      @exchange_in  = channel.direct(Baton.configuration.exchange)
      @exchange_out = channel.direct(Baton.configuration.exchange_out)

      # Attach callbacks for error handling
      @connection.on_tcp_connection_loss(&method(:handle_tcp_failure))
      @channel.on_error(&method(:handle_channel_exception))

	  @service = service
	  @service.setup_consumers
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

    # Public: Provides a new AMQP hostname
    #
    # amqp_hosts - An array of hostnames for your AMQP servers
    #
    # Returns a string of an AMQP hostname.
    #
    def get_new_amqp_host(amqp_hosts)
      amqp_hosts[Kernel.rand(amqp_hosts.size)]
    end

    # Public: Callback to handle TCP connection loss
    #
    # connection - An AMQP Connection
    # settings - Current AMQP settings (see amq-client/lib/amq/client/settings.rb and lib/amq/client/async/adapter.rb)
    #
    # Returns nothing.
    #
    def handle_tcp_failure(connection, settings)

      logger.info("Connection to AMQP lost. Finding new host..")

      if @amqp_hosts.size == 1
        logger.info("Only a single host.. reconnecting")
        connection.reconnect(false, 10)
		@service.setup_consumers
        return
      end

      current_host = settings[:host]
      new_host = get_new_amqp_host(@amqp_hosts)

      while new_host == current_host
        new_host = get_new_amqp_host(@amqp_hosts)
      end

      settings[:host] = new_host

      logger.info ("Reconnecting to AMPQ host: #{new_host}")

      connection.reconnect_to(settings)
	  @service.setup_consumers
    end
  end
end
