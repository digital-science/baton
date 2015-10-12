require 'baton/logging'

module Baton
  class ConsumerManager
    include Baton::Logging
    attr_accessor :consumer, :channel, :exchange_in, :exchange_out

    # Public: Initialize a ConsumerManager and adds itself as an observer to the consumer.
    #
    # consumer - An instance of Baton::Consumer
    # channel - An AMQP channel
    # exchange_in - An input exchange
    # exchange_out - An output exchange
    def initialize(consumer, channel, exchange_in, exchange_out)
      @consumer, @channel, @exchange_in, @exchange_out = consumer, channel, exchange_in, exchange_out
      @consumer.add_observer(self)
      @consumer.consumer_manager = self
    end

    # Public: Creates a queue, binds it to the input exchange based on the consumer's
    # routing key, and subscribes to updates from the queue.
    #
    # Returns nothing.
    def start
      queue = channel.queue("", :exclusive => true, :auto_delete => true)
      queue.bind(exchange_in, :routing_key => consumer.routing_key)
      queue.subscribe do |delivery_info, properties, payload|
        logger.debug "Received #{payload}"
        consumer.handle_message(payload)
      end
      logger.info "Bound queue with routing key '#{consumer.routing_key}' to exchange '#{exchange_in.name}', waiting for messages..."
    end

    # Public: Method that is triggered when a consumer notifies with a message. It
    # logs the messages and writes them to the output exchange as json.
    #
    # message - A general message (Hash, String, etc)
    #
    # Examples
    #
    #   update("A message")
    #
    # Returns nothing.
    def update(message)
      case message.fetch(:type){""}
      when "error"
        logger.error message
      else
        logger.info message
      end
      exchange_out.publish(message.to_json)
    end
  end
end
