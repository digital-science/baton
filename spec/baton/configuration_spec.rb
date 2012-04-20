require "spec_helper"
require "baton/configuration"

describe Baton::Configuration do
  describe "#config_path=" do
    context "given config file available" do
      before(:each) do
        subject.config_path = "#{File.dirname(__FILE__)}/../fixtures/config.cfg"
      end
      
      it "will set the host" do
        subject.host.should eq("fromconfig.com")
      end
      
      it "will set the vhost" do
        subject.vhost.should eq("fromconfig")
      end
      
      it "will set the user" do
        subject.user.should eq("fromconfiguser")
      end
      
      it "will set the password" do
        subject.password.should eq("fromconfigpass")
      end
    end
    
    context "given a non existing file" do
      it "will log an erorr" do
        subject.logger.should_receive(:error).with("Could not find a baton configuration file at bad_path")
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
        subject.connection_opts.should eq({:host=>"fromconfig.com", :vhost=>"fromconfig", :user=>"fromconfiguser", :password=>"fromconfigpass", :pass=>"fromconfigpass"})
      end
    end
    
    context "given one of the configuration options is nil" do
      it "will not be returned in the config hash" do
        subject.vhost = nil
        subject.connection_opts.should eq({:host=>"fromconfig.com", :user=>"fromconfiguser", :password=>"fromconfigpass", :pass=>"fromconfigpass"})        
      end
    end
  end

  describe "multiple amqp hosts" do

    before do
      Kernel.stub!(:rand).and_return(1)
      subject.config_path = "#{File.dirname(__FILE__)}/../fixtures/config-multi.cfg"
    end

    it "will set the host" do
      subject.host.should eq("moreconfig.com")
    end

    it "will have an amqp host list" do
      subject.amqp_host_list.should eq(["fromconfig.com", "moreconfig.com", "thirdconfig.com"])
    end

  end
end
