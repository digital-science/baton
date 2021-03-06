require "spec_helper"

describe Baton::Consumer do

  let(:server) {
    Baton::Server.any_instance.stub(:facts).and_return({
      "fqdn" => "camac.dsci.it",
      "chef_environment" => "production"
    })
    Baton::Server.any_instance.stub(:setup_ohai)
    Baton::Server.new
  }
  let(:payload) { JSON({"type" => "message type" }) }
  let(:subject) { Baton::Consumer.new("deploy-consumer", server) }

  describe "#routing_key" do
    context "given an instance of Baton::Consumer" do
      it "should return a routing key" do
        subject.routing_key.should eq("deploy-consumer.production")
      end
    end
  end

  describe "#exception_notifier" do
    context "given a block that doesn't raise an error" do
      it "should not raise an error" do
        expect{
          subject.exception_notifier do
            a = 1
          end
        }.to_not raise_error
      end
    end

    context "given a block that raises an error" do
      it "should catch the error notify" do
        subject.should_receive(:notify_error)
        subject.exception_notifier do
          raise
        end
      end
    end
  end

  describe "#handle_message" do
    context "given a payload" do
      it "should call process_message" do
        subject.should_receive(:process_message).with(JSON.parse(payload))
        subject.handle_message(payload)
      end
    end
  end

  describe "#attributes" do
    context "given an instance of a consumer" do
      it "should have empty attributes" do
        subject.attributes.should eq({})
      end
    end
  end

end
