require "spec_helper"
require "ostruct"
require "moqueue"

describe Baton::ConsumerManager do

  subject { Baton::ConsumerManager.new(consumer, nil,
                                       mock_exchange({:direct => true}),
                                       mock_exchange({:direct => true})) }
  let(:server) {
    Baton::Server.any_instance.stub(:facts).and_return({
      "fqdn" => "camac.dsci.it",
      "chef_environment" => "production"
    })
    Baton::Server.any_instance.stub(:setup_ohai)
    Baton::Server.new
  }
  let(:consumer) { Baton::Consumer.new("camac", server) }
  let(:metadata) { o = OpenStruct.new ; o.content_type = "application/json"; o }
  let(:payload)  { JSON({"type" => "message type" }) }

  describe "#start" do
    it "will subscribe to a queue using the correct routing key" do
      subject.exchange_in.stub(:name)
      allow_message_expectations_on_nil
      queue = mock("queue")
      queue.should_receive(:bind).with(subject.exchange_in,
                                       routing_key: "camac.production")
      queue.should_receive(:subscribe)
      subject.channel.stub(:queue).and_return(queue)
      subject.start
    end
  end

  describe "#handle_message" do
    include FakeFS::SpecHelpers

    context "given a message" do
      it "should forward the payload to the consumer" do
        subject.consumer.should_receive(:handle_message).with(payload)
        subject.handle_message(metadata, payload)
      end

      it "should call process_message on the consumer" do
        subject.consumer.should_receive(:process_message)
        subject.handle_message(metadata, payload)
      end
    end
  end

  describe "#update" do
    context "given a message is sent to the consumer and the consumer notifies" do
      it "should trigger update with a message" do
        consumer.stub(:process_message) do |message|
          consumer.notify("message from consumer")
        end
        subject.should_receive(:update)
        subject.handle_message(metadata, payload)
      end
    end

    context "given an error message" do
      it "should log the error and publish it to the exchange" do
        message = {:type => "error", :message => "an error message"}
        subject.logger.should_receive(:error).with(message)
        subject.exchange_out.should_receive(:publish)
        subject.update(message)
      end
    end

    context "given an info message" do
      it "should log the info and publish it to the exchange" do
        message = {:type => "info", :message => "an info message"}
        subject.logger.should_receive(:info).with(message)
        subject.exchange_out.should_receive(:publish)
        subject.update(message)
      end
    end
  end
end
