require 'observer'

module Baton
  module Observer
    include Observable

    # Public: Method that notifies errors to observers.
    #
    #  klass - Error class
    #  message - Error message
    #
    # Examples
    #
    #   notify_error(Exception, "Error message")
    #
    # Returns nothing.
    def notify_error(klass, message)
      notify_log({type: "error", error_class: klass, error_message: message})
    end

    # Public: Method that notifies informations to observers.
    #
    #  message - Info message
    #
    # Examples
    #
    #   notify_info("info message")
    #
    # Returns nothing.
    def notify_info(message)
      notify_log({:type => "info", :message => message})
    end

    # Public: Method that notifies success to observers.
    #
    #  message - Success message
    #
    # Examples
    #
    #   notify_success("success message")
    #
    # Returns nothing.
    def notify_success(message)
      notify_log({:type => "success", :message => message})
    end

    # Public: Method that merges attributes to be sent as messages and notifies observers.
    #
    #  attrs - A number of attributes represented by an Hash
    #
    # Examples
    #
    #   notify_log({field_1: "text", :field_2: 123})
    #
    # Returns nothing.
    def notify_log(attrs)
      notify(attributes.merge(attrs))
    end

    # Public: Method that notifies messages to observers.
    #
    #  message - General message
    #
    # Examples
    #
    #   notify("message")
    #
    # Returns nothing.
    def notify(message)
      changed
      notify_observers(message)
    end
  end
end
