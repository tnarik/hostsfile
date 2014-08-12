describe Hostsfile do
  describe "::VERSION" do
    it "exists" do
      expect(Hostsfile::VERSION).not_to be_empty
    end
  end

  describe "::Entry" do
    it "exists" do
      expect(Hostsfile::Entry::respond_to? :new).to eq(true)
    end

    it "#to_line" do
      h = Hostsfile::Entry.new ip_address: "0.0.0.0", hostname: "test"
      expect(h.respond_to? :to_line).to eq(true)
    end

    it "#to_line_response" do
      h = Hostsfile::Entry.new ip_address: "0.0.0.0", hostname: "test"
      expect(h.to_line).to eq("0.0.0.0\ttest")
    end

    it "#to_s" do
      h = Hostsfile::Entry.new ip_address: "0.0.0.0", hostname: "test"
      expect(h.respond_to? :to_line).to eq(true)
    end
  end

  describe "::Manipulator" do
    it "exists" do
      expect(Hostsfile::Manipulator::respond_to? :new).to eq(true)
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
