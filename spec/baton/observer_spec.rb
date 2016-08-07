require "spec_helper"

describe "Baton::Observer module" do

  let(:my_observer) {
    class MyObserver
      include Baton::Observer

      def attributes
        {name: "my_observer_name"}
      end
    end
    MyObserver.new
  }

  describe "#notify_error" do
    context "given an error message" do
      it "should notify the observers about it" do
        expect(my_observer).to receive(:notify_observers).with(
          {:name=>"my_observer_name", :type=>"error", :error_class=>Exception, :error_message=>"an error"})
        my_observer.notify_error(Exception, "an error")
      end
    end
  end

  describe "#notify_info" do
    context "given an info message" do
      it "should notify the observers about it" do
        expect(my_observer).to receive(:notify_observers).with(
          {:name=>"my_observer_name", :type=>"info", :message=>"a message"})
        my_observer.notify_info("a message")
      end
    end
  end

  describe "#notify_success" do
    context "given a success message" do
      it "should notify the observers about it" do
        expect(my_observer).to receive(:notify_observers).with(
          {:name=>"my_observer_name", :type=>"success", :message=>"a success message"})
        my_observer.notify_success("a success message")
      end
    end
  end

  describe "#notify_log" do
    context "given a set or attributes" do
      it "should notify the observers with those attributes" do
        expect(my_observer).to receive(:notify_observers).with(
         {:name=>"my_observer_name", :attr_1=>1, :attr_2=>2})
        my_observer.notify_log({attr_1: 1, attr_2: 2})
      end
    end
  end

end
