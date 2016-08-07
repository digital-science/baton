require "spec_helper"
require "moqueue"
require "ostruct"

describe Baton::ConsumerManager do

  subject { Baton::ConsumerManager.new(consumer, nil,
                                       mock_exchange({:direct => true}),
                                       mock_exchange({:direct => true})) }
  let(:server) {
    allow_any_instance_of(Baton::Server).to receive(:facts).and_return({
      "fqdn" => "camac.dsci.it",
      "chef_environment" => "production"
    })
    allow_any_instance_of(Baton::Server).to receive(:setup_ohai)
    Baton::Server.new
  }
  let(:consumer) { Baton::Consumer.new("camac", server) }
  let(:metadata) { o = OpenStruct.new ; o.content_type = "application/json"; o }
  let(:payload)  { JSON({"type" => "message type" }) }

  describe "#start" do
    it "will subscribe to a queue using the correct routing key" do
      allow(subject.exchange_in).to receive(:name)
      allow_message_expectations_on_nil
      queue = double("queue")
      expect(queue).to receive(:bind).with(subject.exchange_in,
                                       routing_key: "camac.production")
      expect(queue).to receive(:subscribe)
      allow(subject.channel).to receive(:queue).and_return(queue)
      subject.start
    end
  end

  describe "#handle_message" do
    include FakeFS::SpecHelpers

    context "given a message" do
      it "should forward the payload to the consumer" do
        expect(subject.consumer).to receive(:handle_message).with(payload)
        subject.handle_message(metadata, payload)
      end

      it "should call process_message on the consumer" do
        expect(subject.consumer).to receive(:process_message)
        subject.handle_message(metadata, payload)
      end
    end
  end

  describe "#update" do
    context "given a message is sent to the consumer and the consumer notifies" do
      it "should trigger update with a message" do
        allow(consumer).to receive(:process_message) do |message|
          consumer.notify("message from consumer")
        end
        expect(subject).to receive(:update)
        subject.handle_message(metadata, payload)
      end
    end

    context "given an error message" do
      it "should log the error and publish it to the exchange" do
        message = {:type => "error", :message => "an error message"}
        expect(subject.logger).to receive(:error).with(message)
        expect(subject.exchange_out).to receive(:publish)
        subject.update(message)
      end
    end

    context "given an info message" do
      it "should log the info and publish it to the exchange" do
        message = {:type => "info", :message => "an info message"}
        expect(subject.logger).to receive(:info).with(message)
        expect(subject.exchange_out).to receive(:publish)
        subject.update(message)
      end
    end
  end
end
