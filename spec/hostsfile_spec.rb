require 'fakefs/spec_helpers'

describe Hostsfile do
  describe "::VERSION" do
    it "is defined" do
      expect(Hostsfile::VERSION).not_to be_empty
    end
  end

  describe "::Entry" do
    let(:entry) { Hostsfile::Entry.new ip_address: "0.0.0.0", hostname: "test" }

    it "#to_line" do
      expect(entry.respond_to? :to_line).to eq(true)
    end

    it "#to_line_response" do
      expect(entry.to_line).to eq("0.0.0.0\ttest")
    end

    it "#to_s" do
      expect(entry.respond_to? :to_line).to eq(true)
    end
  end
end

## Entry
#    def parse(line)
#    private
#      def extract_comment(line)
#      def extract_priority(comment)
#      def extract_entries(entry)
#      def presence(string)
#
#  def initialize(options = {})
#  def priority=(new_priority)
#  def to_line
#  def to_s
#  def inspect
#  def calculated_priority?
#  private
#    def calculated_priority
