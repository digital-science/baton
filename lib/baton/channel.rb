require "baton/consumer"
require "baton/logging"

module Baton
  class Channel
    include Baton::Logging

    attr_accessor :channel, :exchange_in, :exchange_out, :connection, :connection_options, :amqp_hosts, :last_reconnect_time

    # Public: Initialize a Channel. It creates an AMQP connection, a channel,
    # an input and an output exchange and finally attaches the handle_channel_exception
    # callback to the on_error event on the channel.
    def initialize
      
      @connection_options = Baton.configuration.connection_opts
      @amqp_hosts = Baton.configuration.amqp_host_list

      logger.info "Connecting to AMQP host: #{@connection_options[:host]}:#{@connection_options[:port]}"
       
      @reconnect_wait = 5
      @last_reconnect_time = Time.new
      @connection   = AMQP.connect(@connection_options)
      @channel      = AMQP::Channel.new(@connection)
      @channel.auto_recovery = true

      # Not everything needs an input exchange, default to the "" exchange if there isn't
      # one defined in the config (monitors for example)
      Baton.configuration.exchange = '' if Baton.configuration.exchange.nil?

      # Create the exchanges
      # Input exchange is how baton receives messages
      # Output exchange is how baton returns output
      @exchange_in  = channel.direct(Baton.configuration.exchange)
      if Baton.configuration.exchange_out.nil? || Baton.configuration.exchange_out.empty?
        logger.error "An output exchange must be configured. Exiting."
        exit 1
      else
        @exchange_out = channel.direct(Baton.configuration.exchange_out)
      end

      # Attach callbacks for error handling
      @connection.on_tcp_connection_loss(&method(:handle_tcp_loss))
      @connection.on_tcp_connection_failure(&method(:handle_tcp_failure))
      @connection.on_possible_authentication_failure(&method(:handle_authentication_failure))
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
    def handle_tcp_loss(connection, settings)

      # if we tried to reconnect within the last @reconnect_wait seconds, do nothing
      if @last_reconnect_time > Time.new - @reconnect_wait
	return
      end

      logger.info("Connection to AMQP host lost. Finding new host...")

      if @amqp_hosts.size == 1
        logger.info("Only a single host (#{settings[:host]}); reconnecting...")
	@last_reconnect_time = Time.new
        connection.reconnect(true)
        return
      end

      current_host = settings[:host]
      new_host = get_new_amqp_host(@amqp_hosts)

      while new_host == current_host
        new_host = get_new_amqp_host(@amqp_hosts)
      end

      settings[:host] = new_host

      logger.info("Connecting to new AMQP host: #{new_host}")

      connection.reconnect_to(settings)

      @last_reconnect_time = Time.new
    end

    def handle_tcp_failure(settings)
      logger.error("Initial connection to server #{settings[:host]}:#{settings[:port]} failed");

      exit 1
    end

    def handle_authentication_failure(settings)
      logger.error("Authentication failed with settings:\n#{settings.inspect}");

      exit 1
    end
  end
end
