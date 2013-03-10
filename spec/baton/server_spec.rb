require "spec_helper"
require "baton/server"

describe Baton::Server do

  context "stubbed ohai" do

    before(:each) do
      Baton::Server.any_instance.stub(:facts).and_return({
        "chef_environment" => "production",
        "fqdn" => "build-prod-i-722b0004.dsci.it",
        "trebuchet" => ["octobutler"]
      })
      Baton::Server.any_instance.stub(:setup_ohai)
    end

    describe "#configure" do
      context "given data from Ohai" do

        it "will set the fqdn" do
          subject.fqdn.should eq("build-prod-i-722b0004.dsci.it")
        end

        it "will set the environment" do
          subject.environment.should eq("production")
        end

        it "will set the apps" do
          subject.app_names.first.should eq("octobutler")
        end
      end

      context "given the required facts are not available" do
        before(:each) do
          Baton::Server.any_instance.stub(:facts).and_return({})
          Baton::Server.any_instance.stub(:setup_ohai)
          subject.configure
        end

        it "will default the fqdn to an empty string" do
          subject.fqdn.should be_empty
        end

        it "will default environment to development" do
          subject.environment.should eq("development")
        end

        it "will default apps to an empty array" do
          subject.app_names.should be_empty
        end
      end
    end

    describe "#attributes" do
      context "given an instance of a server" do
        it "should have the attributes set" do
          subject.attributes.should eq({:environment=>"production",
                                        :fqdn=>"build-prod-i-722b0004.dsci.it",
                                        :app_names=>["octobutler"]})
        end
      end
    end
  end

  context "ohai integration" do
    before(:each) do
      ohai_fixtures = File.expand_path('../../fixtures/ohai_plugins', __FILE__)
      Baton::Server.any_instance.stub(:ohai_plugin_path).and_return(ohai_fixtures)
    end

    describe "#environment" do
      context "production" do
        it "should have the correct environment set" do
          Baton::Server.new.environment.should eq('production')
        end
      end
    end
  end
end
