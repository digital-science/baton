# Baton - Server Orchestration Tool

[![Build Status](https://secure.travis-ci.org/digital-science/baton.png)](http://travis-ci.org/digital-science/baton)

## Description

Baton is a general purpose server orchestration tool.

## Getting Started

    git clone git@github.com:digital-science/baton.git
    cd baton
    bundle install

## Testing

    bundle exec rspec

## Install

You can either:

    gem install baton

Or, in your Gemfile:

    gem 'baton'

## How to use

Please check an existing extension, e.g. [baton-ping](https://github.com/digital-science/baton-ping), for more information about how to use and extend baton. 
Since baton was created as a base for other extensions, it doesn't do anything in particular by itself but provide the structure and a basic setup on top of RabbitMQ and EventMachine.

## Submitting a Pull Request

1. [Fork the repository.](https://help.github.com/articles/fork-a-repo)
2. [Create a topic branch.](http://learn.github.com/p/branching.html)
3. Add specs for your unimplemented feature or bug fix.
4. Run `bundle exec rake test`. If your specs pass, return to step 3.
5. Implement your feature or bug fix.
6. Run `bundle exec rake test`. If your specs fail, return to step 5.
7. Run `open coverage/index.html`. If your changes are not completely covered
   by your tests, return to step 3.
8. Add documentation for your feature or bug fix.
9. Add, commit, and push your changes.
10. [Submit a pull request.](https://help.github.com/articles/using-pull-requests)

## Details and Building Extensions

Baton relies on [EventMachine](http://rubyeventmachine.com/) and [AMQP](http://rubyamqp.info/) for message passing. The gem defines a basic set of classes operating on top of RabbitMQ. The initial configuration will setup an input exchange and an output exchange. 

On the input exchange, baton will wait for meaningful messages to perform actions (described by each service) and it will output messages to the output exchange.

### API

This is the entry point for input messages. One should extend the API class and add meaningful methods that ultimately use `publish` to publish messages to the input exchange. One example can be found [here](https://github.com/digital-science/baton-ping/blob/master/lib/baton/baton-ping/api.rb#L8)

### Executable script

Any baton extension should have an executable script that will start the extension service. [Here](https://github.com/digital-science/baton-ping/blob/master/bin/baton-ping) is an example.

### Service

The Service is the starting point of any baton extension. The idea of the service is to setup consumers for the input messages arriving from the API. By implementing `setup_consumers` one will allow the consumers to receive messages. [Here](https://github.com/digital-science/baton-ping/blob/master/lib/baton/baton-ping.rb) is an example.

### Consumer Manager

This class is an orchestration class that attaches observers to the consumers (like logger, etc), binds the input queues to the correct exchanges, dispatches the received messages to the consumers and updates the observers on changes. One doesn't need to extend this class unless one wants to change its behaviour.

### Consumer

This class must be extended in order to process each received message. One should implement `process_message` at least, in order to give meaning to each received message. One can also override `routing_key` in order to listen to specific messages. [Here](https://github.com/digital-science/baton-ping/blob/master/lib/baton/baton-ping/ping_consumer.rb) is an example of an implementation.

### Channel

Like the consumer manager, this class doesn't need to be extended. It provides functionality to setup the exchanges and add consumers. 

### Observer

The observer class provides methods to notify observers. It is by default included in the consumers so that the output exchange (and possibly loggers, etc) receive the output messages.

## Minimal Extension

You can easily extend baton to perform your own tasks. [baton-ping](https://github.com/digital-science/baton-ping) provides what we consider to be a minimal extension to baton. One should note that there is an extra class on `baton-ping` called [monitor](https://github.com/digital-science/baton-ping/blob/master/lib/baton/baton-ping/monitor.rb). This is a good example of what to do with output messages from a baton extension. Together with [baton-ping-monitor](https://github.com/digital-science/baton-ping/blob/master/bin/baton-ping-monitor), it provides a standard way of consuming output messages and do something relevant with them.

If you would like to create your own extension, simply install baton (`gem install baton`) and run the following command:

    batonize gem GEMNAME -b

This will create a basic gem structure with the necessary files to create a minimum viable baton extension.
