require "spec_helper"

describe Baton::Configuration do
  describe "#config_path=" do
    context "given config file available" do

      before(:each) do
        subject.config_path = "#{File.dirname(__FILE__)}/../fixtures/config.cfg"
      end

      it "will set the host" do
        expect(subject.host).to eq("fromconfig.com")
      end

      it "will set the port" do
        expect(subject.port).to eq(12345)
      end

      it "will set the vhost" do
        expect(subject.vhost).to eq("fromconfig")
      end

      it "will set the user" do
        expect(subject.user).to eq("fromconfiguser")
      end

      it "will set the password" do
        expect(subject.password).to eq("fromconfigpass")
      end

      it "will set the heartbeat" do
        expect(subject.heartbeat).to eq(666)
      end
    end

    context "given a non existing file" do
      it "will log an erorr" do
        expect(subject.logger).to receive(:error).with("Could not find a baton configuration file at bad_path")
        subject.config_path = "bad_path"
      end
    end
  end

  describe "#connection_opts" do
    before(:each) do
      subject.config_path = "#{File.dirname(__FILE__)}/../fixtures/config.cfg"
    end

    context "give a config file" do
      it "will return a config hash" do
        expect(subject.connection_opts).to eq({
          host:      "fromconfig.com",
          port:      12345,
          vhost:     "fromconfig",
          user:      "fromconfiguser",
          password:  "fromconfigpass",
          pass:      "fromconfigpass",
          heartbeat: 666
        })
      end
    end

    context "given one of the configuration options is nil" do
      it "will not be returned in the config hash" do
        subject.vhost = nil
        expect(subject.connection_opts).to eq({
          host:      "fromconfig.com",
          port:      12345,
          user:      "fromconfiguser",
          password:  "fromconfigpass",
          pass:      "fromconfigpass",
          heartbeat: 666
        })
      end
    end
  end

  describe "multiple amqp hosts" do

    before do
      allow(Kernel).to receive(:rand).and_return(1)
      subject.config_path = "#{File.dirname(__FILE__)}/../fixtures/config-multi.cfg"
    end

    it "will set the host" do
      expect(subject.host).to eq("moreconfig.com")
    end

    it "will have an amqp host list" do
      expect(subject.amqp_host_list).to eq(["fromconfig.com", "moreconfig.com", "thirdconfig.com"])
    end

    it "will default the heartbeat to 60" do
      expect(subject.heartbeat).to eq(60)
    end

  end
end
