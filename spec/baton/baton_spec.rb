require "spec_helper"

describe Baton do
  describe ".configure" do
    it "will allow configuration by passing a block in" do
      Baton.configure do |c|
        c.pusher_key = "foo"
      end
      expect(Baton.configuration.pusher_key).to eq("foo")
    end
  end
end
