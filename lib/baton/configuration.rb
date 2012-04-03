require "yaml"
require "baton/logging"

module Baton
  class Configuration
    include Baton::Logging

    attr_accessor :exchange, :exchange_out, :ohai_file,
      :host, :vhost, :user, :password,
      :pusher_app_id, :pusher_key, :pusher_secret, :config_path

    # Public: Loads the config file given as parameter and sets up RabbitMQ's options.
    #
    # path - A file path representing a config file
    #
    # Examples
    #
    #   config_file = "/path/to/file"
    #
    # Returns nothing.
    # Raises Errno::ENOENT if file cannot be found.
    def config_path=(path)
      config_file = YAML.load_file(path)
      setup_rabbitmq_opts(config_file)
    rescue Errno::ENOENT => e
      self.host = "localhost"
      logger.error "Could not find a baton configuration file at #{path}"
    end

    # Public: Setup RabbitMQ's options from a config file.
    #
    # config_file - A hash representing a config file
    #
    # Examples
    #
    #   setup_rabbitmq_opts({
    #     "RABBIT_HOST" => "localhost",
    #     "RABBIT_VHOST" => "baton",
    #     "RABBIT_USER" => "baton",
    #     "RABBIT_PASS" => "password"
    #     })
    #
    # Returns nothing.
    def setup_rabbitmq_opts(config_file)
      self.host     = config_file.fetch("RABBIT_HOST") {"localhost"}
      self.vhost    = config_file["RABBIT_VHOST"]
      self.user     = config_file["RABBIT_USER"]
      self.password = config_file["RABBIT_PASS"]
    end

    # Public: Defines the connection options for RabbitMQ as a Hash.
    #
    # Examples
    #
    #   connection_options
    #   # => {:host=>"localhost", :vhost=>"baton", :user=>"baton", :password=>"password"}
    #
    # Returns a hash of RabbitMQ connection options.
    def connection_opts
      {:host => host, :vhost => vhost, :user => user, :password => password, :pass => password}.delete_if{|k,v| v.nil?}
    end
  end
end
