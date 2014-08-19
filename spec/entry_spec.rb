require 'fakefs/spec_helpers'

describe Hostsfile do
  describe "::Entry" do
    let(:entry) { Hostsfile::Entry.new ip_address: "0.0.0.0", hostname: "test" }

    context "#parse" do
      it "raises a fatal error if the hostname is missing (considers the first field the IP" do
        expect { Hostsfile::Entry.parse "0.0.0.0"}.to raise_error(ArgumentError, /Hostsfile has a line without hostname/)
        expect { Hostsfile::Entry.parse "       hostname"}.to raise_error(ArgumentError, /Hostsfile has a line without hostname/)
        expect { Hostsfile::Entry.parse "       \thostname"}.to raise_error(ArgumentError, /Hostsfile has a line without hostname/)
        expect { Hostsfile::Entry.parse "\thostname"}.to raise_error(ArgumentError, /Hostsfile has a line without hostname/)
      end
    end

    context "#to_line" do
      it "exists" do
        expect(entry.respond_to? :to_line).to eq(true)
      end

      it "generates a proper line" do
        expect(entry.to_line).to eq("0.0.0.0\ttest")
      end
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
