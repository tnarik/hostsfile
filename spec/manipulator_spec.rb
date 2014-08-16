require 'fakefs/spec_helpers'

describe Hostsfile do
  describe "::Manipulator" do 
    include FakeFS::SpecHelpers

    before(:each) do
      fixture_to_fakefs("sample_hosts", "/etc/hosts")
    end

    let(:manipulator) { Hostsfile::Manipulator.new }

    context "#initialize" do
      it "raises a fatal error if the hostfile does not exist" do
        expect { Hostsfile::Manipulator.new "/etc/hosts_does_not_exist"}.to raise_error(RuntimeError)
      end

      it "reads the default /etc/hosts file if none is specified" do
        expect { Hostsfile::Manipulator.new }.to_not raise_error
        expect(Hostsfile::Manipulator.new.ip_addresses.size).to be(3)
      end
    end

    context "#ip_addresses" do
      it "reads ip addresses correctly" do
        expect(manipulator.ip_addresses.size).to be(3)
      end
    end

    context "#add" do
      let(:options) { { ip_address: '192.0.2.0', hostname: 'example.com', aliases: nil, comment: 'Some comment', priority: 5 } }
      let(:minimal_options) { { ip_address: '192.0.2.0', hostname: 'example.com' } }

      it "requires at least IP Address and Hostname" do
        expect { manipulator.add(ip_address: options[:ip_address]) }.to raise_error(ArgumentError)
        expect { manipulator.add(hostname: options[:hostname]) }.to raise_error(ArgumentError)
        expect { manipulator.add(aliases: options[:aliases]) }.to raise_error(ArgumentError)
        expect { manipulator.add(comment: options[:comment]) }.to raise_error(ArgumentError)

        expect { manipulator.add(options.reject {|k| k == :ip_address}) }.to raise_error(ArgumentError)
        expect { manipulator.add(options.reject {|k| k == :hostname}) }.to raise_error(ArgumentError)

        expect { manipulator.add(minimal_options) }.to change{manipulator.ip_addresses.size}.from(3).to(4)
      end

      it "add entries in memory until save" do # Includes debugging
        expect { manipulator.add(options) }.to change{manipulator.ip_addresses.size}.from(3).to(4)
        refreshed_manipulator = Hostsfile::Manipulator.new
        expect(refreshed_manipulator.ip_addresses.size).to be(3)
        manipulator.save
        refreshed_manipulator = Hostsfile::Manipulator.new
        expect(refreshed_manipulator.ip_addresses.size).to be(4)
        puts File.read("/etc/hosts")
      end
    end

    context "#update" do
      let(:options) { { ip_address: '127.0.0.1', hostname: 'new.example.com' } }
      let(:not_existing_options) { { ip_address: '192.0.2.0', hostname: 'new.example.com' } }
      context "when the entry exists" do
        it "does not add a new entry" do
          expect { manipulator.update(options) }.not_to change{manipulator.ip_addresses.size}
        end

        it "updates the entry" do  # Includes debugging
          p manipulator.find_entry_by_ip_address(options[:ip_address])
          expect { manipulator.update(options) }.to change{manipulator.find_entry_by_ip_address(options[:ip_address]).hostname}
          expect( manipulator.find_entry_by_ip_address(options[:ip_address]).hostname ).to eq(options[:hostname])
          p manipulator.find_entry_by_ip_address(options[:ip_address])
        end
      end
      context "when the entry does not exist" do
        it "does nothing" do
          expect { manipulator.update(not_existing_options) }.not_to change{manipulator.ip_addresses.size}
        end
      end
    end

    context "#append" do
      let(:options) { { ip_address: '127.0.0.1', hostname: 'new.example.com', aliases: "alias.example.com", comment: 'Some comment', priority: 5  } }
      let(:not_existing_options) { { ip_address: '192.0.2.0', hostname: 'example.com', aliases: nil, comment: 'Some comment', priority: 5 } }
      let(:unique_options) { { ip_address: '192.0.2.2', hostname: 'awesome.example.com', aliases: nil, comment: 'Moved IPs for awesome.example.com', unique: true } }

      context "when the entry exists by IP" do
        it "does not update hostname, instead adds the new one as an alias" do
          original_entry = manipulator.find_entry_by_ip_address(options[:ip_address])
          expect { manipulator.append(options) }.not_to change{manipulator.ip_addresses.size}
          expect( manipulator.find_entry_by_ip_address(options[:ip_address]).hostname ).to eq(original_entry.hostname)
          expect( manipulator.find_entry_by_ip_address(options[:ip_address]).aliases ).to include("new.example.com")
        end
        it "updates aliases" do
          expect { manipulator.append(options) }.not_to change{manipulator.ip_addresses.size}
          expect( manipulator.find_entry_by_ip_address(options[:ip_address]).aliases ).to include("alias.example.com")
        end
        it "updates comment" do
          expect { manipulator.append(options) }.not_to change{manipulator.ip_addresses.size}
          expect( manipulator.find_entry_by_ip_address(options[:ip_address]).comment ).to eq(options[:comment])
        end
      end

      context "when the entry exists by hostname" do
        it "replaces it if unique" do
          original_entry = manipulator.find_entry_by_ip_address('192.0.2.1')
          expect( original_entry.hostname ).to eq(unique_options[:hostname])
          expect { manipulator.append(unique_options) }.not_to change{manipulator.ip_addresses.size}
          expect( manipulator.find_entry_by_ip_address(unique_options[:ip_address]).hostname ).to eq(unique_options[:hostname])
          expect( manipulator.find_entry_by_ip_address(original_entry.ip_address) ).to be_nil
        end
        it "adds a new entry if not unique" do
          original_entry = manipulator.find_entry_by_ip_address('192.0.2.1')
          expect( original_entry.hostname ).to eq(unique_options[:hostname])
          expect { manipulator.append(unique_options.reject {|k| k == :unique}) }.to change{manipulator.ip_addresses.size}.from(3).to(4)
          expect( manipulator.find_entry_by_ip_address(unique_options[:ip_address]).hostname ).to eq(unique_options[:hostname])
          expect( manipulator.find_entry_by_ip_address(original_entry.ip_address) ).not_to be_nil
        end
      end
      context "when the entry does not exist" do
        it "adds the new entry" do
          expect { manipulator.append(not_existing_options) }.to change{manipulator.ip_addresses.size}.from(3).to(4)
          expect( manipulator.find_entry_by_ip_address(not_existing_options[:ip_address]).hostname ).to eq('example.com')
        end
      end
    end

    context "#remove" do
      context "when the entry exists" do
        it "is removed" do
          expect { manipulator.remove('127.0.0.1') }.to change{manipulator.ip_addresses.size}.from(3).to(2)
        end
      end
      context "when the entry does not exist" do
        it "does nothing" do
          expect { manipulator.remove('192.0.2.0') }.not_to change{manipulator.ip_addresses.size}
        end
      end
    end

    context '#find_entry_by_ip_address' do
      it 'finds the associated entry' do
        expect( manipulator.find_entry_by_ip_address('127.0.0.1') ).not_to be_nil
      end
  
      it 'returns nil if the entry does not exist' do
        expect( manipulator.find_entry_by_ip_address('192.0.2.0') ).to be_nil
      end
    end

    # Contains will probably dissapear, as it links to entries specifically

    it "ip addresses are removed works on memory" do
      expect(manipulator.ip_addresses.size).to be(3)
      manipulator.add(ip_address: '192.0.2.0', hostname: 'test')
      expect(manipulator.ip_addresses.size).to be(4)
      expect { manipulator.remove('192.0.2.0') }.to change{manipulator.ip_addresses.size}.from(4).to(3)
    end

  end
end

## Manipulator
#  def initialize(path = nil, family = nil, system_directory = nil)
#  def ip_addresses
#  def add(options = {})
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
