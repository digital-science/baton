require 'baton'
require 'amqp'
require 'eventmachine'
require 'em-http-request'
require 'json'
require 'baton/channel'
require 'baton/server'
require 'baton/consumer_manager'

module Baton
  class Service
    include Baton::Logging

    attr_accessor :server, :channel, :daemonize

    # Public: Initialize a Service. Sets up a new server for this service.
    def initialize(daemonize=false)
      @server = Baton::Server.new
      @daemonize = daemonize
      @pid_file = Baton.configuration.pid_file || "/var/run/baton.pid"
      Baton::Logging.logger = Baton.configuration.log_file || STDOUT
    end

    # Public: Method that starts the service.
    #
    # Returns nothing.
    def go
      logger.info "Starting Baton v#{Baton::VERSION}"
      EM.run do
        Signal.trap('INT') { stop }
        Signal.trap('TERM'){ stop }
        @channel = Baton::Channel.new
        setup_consumers
      end
    end

    def run
      if @daemonize
        pid = get_pid

        if pid != 0 
          logger.error "Baton is already running! (PID: #{pid})"
          exit -1
        end

        pid = fork { go }

        begin
          File.open(@pid_file, "w") { |f| f.write pid }
          Process.detach(pid)
        rescue => exc
          Process.kill('TERM', pid)
          logger.error "Couldn't daemonize: #{exc.message}"
        end
      else
        go
      end
    end

    def stop
      if @daemonize
        pid = get_pid
        begin
          EM.stop
        rescue
        end

        if pid != 0
          Process.kill('HUP', pid.to_i)
          File.delete(@pid_file)
          logger.info "Stopped"
        else
          logger.warn "Daemon not running"
          exit -1
        end
      else
        EM.stop
      end
    end

    # Get the PID of the running daemon
    #
    # Returns the PID of the daemon
    def get_pid
      File.exists?(@pid_file) ? File.read(@pid_file).strip : 0
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
