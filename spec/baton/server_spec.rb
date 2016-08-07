require "spec_helper"

describe Baton::Server do

  context "stubbed ohai" do

    before(:each) do
      allow_any_instance_of(Baton::Server).to receive(:facts).and_return({
        "chef_environment" => "production",
        "fqdn" => "build-prod-i-722b0004.dsci.it",
        "trebuchet" => ["octobutler"]
      })
      allow_any_instance_of(Baton::Server).to receive(:setup_ohai)
    end

    describe "#configure" do
      context "given data from Ohai" do

        it "will set the fqdn" do
          expect(subject.fqdn).to eq("build-prod-i-722b0004.dsci.it")
        end

        it "will set the environment" do
          expect(subject.environment).to eq("production")
        end

        it "will set the apps" do
          expect(subject.app_names.first).to eq("octobutler")
        end
      end

      context "given the required facts are not available" do
        before(:each) do
          allow_any_instance_of(Baton::Server).to receive(:facts).and_return({})
          allow_any_instance_of(Baton::Server).to receive(:setup_ohai)
          subject.configure
        end

        it "will default the fqdn to an empty string" do
          expect(subject.fqdn).to be_empty
        end

        it "will default environment to development" do
          expect(subject.environment).to eq("development")
        end

        it "will default apps to an empty array" do
          expect(subject.app_names).to be_empty
        end
      end
    end

    describe "#attributes" do
      context "given an instance of a server" do
        it "should have the attributes set" do
          expect(subject.attributes).to eq({:environment=>"production",
                                        :fqdn=>"build-prod-i-722b0004.dsci.it",
                                        :app_names=>["octobutler"]})
        end
      end
    end
  end

  context "ohai integration" do
    before(:each) do
      ohai_fixtures = File.expand_path('../../fixtures/ohai_plugins', __FILE__)
      allow_any_instance_of(Baton::Server).to receive(:ohai_plugin_path).and_return(ohai_fixtures)
    end

    describe "#environment" do
      context "production" do
        it "should have the correct environment set" do
          expect(Baton::Server.new.environment).to eq('production')
        end
      end
    end
  end
end
