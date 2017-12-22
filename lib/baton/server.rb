require "ohai"
require "yaml"

module Baton
  class Server

    attr_accessor :environment, :fqdn, :app_names

    # Public: Initializes a server. Loads Ohai plugins and sets up basic
    # server info, such as environment, fqdn and app names.
    def initialize
      setup_ohai
      configure
    end

    # Public: Method that configures the server. It sets the fqdn, environment and a list
    # of app names specified by the ohai config file.
    #
    # Returns nothing.
    def configure
      baton_config = YAML.load_file('/etc/baton/baton-env.cfg')
      @environment = baton_config['CHEF_ENVIRONMENT'].downcase
      @fqdn        = facts.fetch("fqdn"){""}
      @app_names   = facts.fetch("trebuchet"){[]}
    end

    # Public: Method that reads facts from the file specified by facts_file.
    #
    # Examples
    #
    #   facts
    #   # => {"fqdn" => "server.dsci.it", "chef_environment" => "production", "trebuchet" => []}
    #
    # Returns a hash with server information.
    def facts
      @facts ||= @ohai.data
    end

    # Public: Method that provides an hash of attributes for a server.
    #
    # Examples
    #
    #   attributes
    #   # => {environment: "production", fqdn: "server.dsci.it", app_names: ["app1","app2"]}
    #
    # Returns Output depends on the implementation.
    def attributes
      {environment: environment, fqdn: fqdn, app_names: app_names}
    end

    private

    # Private: Path where ohai plugins are
    def ohai_plugin_path
      "/etc/chef/ohai_plugins"
    end

    # Load Ohai plugins from the server
    def setup_ohai
      Ohai::Config[:plugin_path] << ohai_plugin_path
      @ohai = Ohai::System.new
      @ohai.all_plugins
    end

  end
end
