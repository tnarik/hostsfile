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

  describe "::Manipulator" do 
    include FakeFS::SpecHelpers

    before(:each) do
      fixture_to_fakefs("ipv4", "/etc/hosts")
    end

    let(:manipulator) { Hostsfile::Manipulator.new }

    it "reads ip addresses correctly" do
      expect(manipulator.ip_addresses.size).to be(2)
    end

    it "can add ip addresses" do
      expect { manipulator.add(ip_address: '192.0.2.0', hostname: 'test') }.to change{manipulator.ip_addresses.size}.from(2).to(3)
      refreshed_manipulator = Hostsfile::Manipulator.new
      expect(refreshed_manipulator.ip_addresses.size).to be(2)
      manipulator.save
      refreshed_manipulator = Hostsfile::Manipulator.new
      expect(refreshed_manipulator.ip_addresses.size).to be(3)
    end

    it "ip addresses are added in memory only until save" do
      manipulator.add(ip_address: '192.0.2.0', hostname: 'test')
      refreshed_manipulator = Hostsfile::Manipulator.new
      expect(refreshed_manipulator.ip_addresses.size).to be(2)
      manipulator.save
      refreshed_manipulator = Hostsfile::Manipulator.new
      expect(refreshed_manipulator.ip_addresses.size).to be(3)
    end

    it "ip addresses are removed if existing" do
      expect { manipulator.remove('127.0.0.1') }.to change{manipulator.ip_addresses.size}.from(2).to(1)
    end

    it "ip addresses are not removed if not existing" do
      expect { manipulator.remove('192.0.2.0') }.not_to change{manipulator.ip_addresses.size}
    end

    it "ip addresses are removed works on memory" do
      expect(manipulator.ip_addresses.size).to be(2)
      manipulator.add(ip_address: '192.0.2.0', hostname: 'test')
      expect(manipulator.ip_addresses.size).to be(3)
      expect { manipulator.remove('192.0.2.0') }.to change{manipulator.ip_addresses.size}.from(3).to(2)
    end


    #it "#append" do
    #  h = Hostsfile::Manipulator.new
    #  expect(h.respond_to? :append).to eq(true)
    #end
  end
end

## Manipulator
#  def initialize(path = nil, family = nil, system_directory = nil)
#  def ip_addresses
#  def add(options = {})
#  def update(options = {})
#  def append(options = {})
#  def remove(ip_address)
#  def save
#  def find_entry_by_ip_address(ip_address)
#  def contains?(resource)
#  private
#    def hostsfile_path (path = nil, family = nil, system_directory = nil)
#    def current_sha
#    def normalize(*things)
#    def unique_entries
#    def collect_and_flatten(contents)
#    def remove_existing_hostnames(entry)


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
