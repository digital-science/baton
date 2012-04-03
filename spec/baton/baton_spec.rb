require "spec_helper"
require "baton"

describe Baton do
  describe ".configure" do
    it "will allow configuration by passing a block in" do
      Baton.configure do |c|
        c.pusher_key = "foo"
      end
      Baton.configuration.pusher_key.should eq("foo")
    end
  end
end