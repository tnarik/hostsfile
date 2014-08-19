require 'fakefs/spec_helpers'

describe Hostsfile do
  describe "::VERSION" do
    it "is defined" do
      expect(Hostsfile::VERSION).not_to be_empty
    end
  end
end
