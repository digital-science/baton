require "spec_helper"
require "baton/service"

describe Baton::Service do
  let(:pid_file) { "/tmp/test-baton-daemon.pid" }
  before(:each) do
    Baton::Service.any_instance.stub(:setup_consumers) { EM.stop }
    Baton.configuration.pid_file = pid_file
    Baton::Channel.stub(:new).and_return(nil)
    File.delete(pid_file) if File.exists?(pid_file)
    logger = double("logger")
    logger.stub(:info)
    logger.stub(:error)
    Baton::Service.any_instance.stub(:logger).and_return(logger)
  end

  describe "daemonising" do
    context "daemonize = true" do
      subject { Baton::Service.new(true) }

      it "should call daemon" do
        Process.should_receive(:daemon)
        subject.run
      end
    end
  end
end

