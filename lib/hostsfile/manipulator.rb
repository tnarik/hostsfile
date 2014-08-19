# Copyright 2013-14, Tnarik Innael (for the modifications)
#
# from customink-webops/hostsfile/libraries/manipulator.rb :
# Copyright 2012-2013, Seth Vargo
# Copyright 2012, CustomInk, LCC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'digest/sha2'

module Hostsfile

class Manipulator
  attr_reader :entries
  # Create a new Manipulator object (aka an /etc/hosts manipulator). If a
  # hostsfile is not found, a Exception is risen.
  # Parameters are optional (see #hostsfile_path)
  #
  # @param [String] path
  #   the file path for the host file
  # @param [String] family
  #   the OS family ('windows' or anything else for POSIX support)
  # @param [String] system_directory
  #   System directory for the 'windows' family (like C:\\Windows\\system32)
  # @return [Manipulator]
  #   a class designed to manipulate the /etc/hosts file
  def initialize(path = nil, family = nil, system_directory = nil)
    # Fail if no hostsfile is found
    unless ::File.exists?(hostsfile_path(path, family, system_directory))
      raise "No hostsfile exists at '#{hostsfile_path}'!"
    end

    @entries = []
    collect_and_flatten(::File.readlines(hostsfile_path))
  end

  # Return a list of all IP Addresses for this hostsfile.
  #
  # @return [Array<IPAddr>]
  #   the list of IP Addresses
  def ip_addresses
    @entries.collect do |entry|
      entry.ip_address
    end.compact || []
  end

  # Add a new record to the hostsfile.
  #
  # @param [Hash] options
  #   a list of options to create the entry with
  # @option options [String] :ip_address
  #   the IP Address for this entry
  # @option options [String] :hostname
  #   the hostname for this entry
  # @option options [String, Array<String>] :aliases
  #   a alias or array of aliases for this entry
  # @option options[String] :comment
  #   an optional comment for this entry
  # @option options [Fixnum] :priority
  #   the relative priority of this entry (compared to others)
  def add(options = {})
    entry = ::Hostsfile::Entry.new(
      ip_address: options[:ip_address],
      hostname:   options[:hostname],
      aliases:    options[:aliases],
      comment:    options[:comment],
      priority:   options[:priority],
    )

    @entries << entry
    remove_existing_hostnames(entry) if options[:unique]
  end

  # Update an existing entry. This method will do nothing if the entry
  # does not exist.
  #
  # @param (see #add)
  def update(options = {})
    if entry = find_entry_by_ip_address(options[:ip_address])
      entry.hostname  = options[:hostname]
      entry.aliases   = options[:aliases]
      entry.comment   = options[:comment]
      entry.priority  = options[:priority]

      remove_existing_hostnames(entry) if options[:unique]
    end
  end

  # Append content to an existing entry. This method will add a new entry
  # if one does not already exist.
  #
  # @param (see #add)
  def append(options = {})
    if entry = find_entry_by_ip_address(options[:ip_address])
      hosts          = normalize(entry.hostname, entry.aliases, options[:hostname], options[:aliases])
      entry.hostname = hosts.shift
      entry.aliases  = hosts

      unless entry.comment && options[:comment] && entry.comment.include?(options[:comment])
        entry.comment = normalize(entry.comment, options[:comment]).join(', ')
      end

      remove_existing_hostnames(entry) if options[:unique]
    else
      add(options)
    end
  end

  # Remove an entry by it's IP Address
  #
  # @param [String] ip_address
  #   the IP Address of the entry to remove
  def remove(ip_address)
    if entry = find_entry_by_ip_address(ip_address)
      @entries.delete(entry)
    end
  end

  # Save the new hostsfile to the target machine. This method will only write the
  # hostsfile if the current version has changed. In other words, it is convergent.
  def save
    # Only write out the file if the contents have changed...
    ::File.open(hostsfile_path, 'w') do |f|
      f.write(new_content)
    end if content_changed?
  end

  # Determine if the content of the hostfile has changed by comparing sha
  # values of existing file and new content
  #
  # @return [Boolean]
  def content_changed?
    new_sha = Digest::SHA512.hexdigest(new_content)
    new_sha != current_sha
  end

  # Find an entry by the given IP Address.
  #
  # @param [String] ip_address
  #   the IP Address of the entry to find
  # @return [Entry, nil]
  #   the corresponding entry object, or nil if it does not exist
  def find_entry_by_ip_address(ip_address)
    @entries.find do |entry|
      !entry.ip_address.nil? && entry.ip_address == ip_address
    end
  end

  # Determine if the current hostsfile contains the given resource. This
  # is really just a proxy to {find_resource_by_ip_address} /
  #
  # @param [String] ip_address
  #   the IP Address of the entry to check
  # @return [Boolean]
  def contains?(ip_address)
    !!find_entry_by_ip_address(ip_address)
  end

  private
  # The path to the current hostsfile.
  # If not path is provided, a default is guessed based on 'family' and 'system_directory'
  # If path is provided, it takes priority
  #
  # @param [String] path
  #   the file path for the host file
  # @param [String] family
  #   the OS family ('windows' or anything else for POSIX support)
  # @param [String] system_directory
  #   System directory for the 'windows' family (default C:\\Windows\\system32)
  # @return [String]
  #   the full path to the hostsfile, depending on the operating system
  def hostsfile_path (path = nil, family = nil, system_directory = nil)
    return @hostsfile_path if @hostsfile_path
    @hostsfile_path = path || case family
                                when 'windows'
                                  system_directory ||= File.join('C:','Windows','system32')
                                  File.join("#{system_directory}", 'drivers', 'etc', 'hosts')
                                else
                                  '/etc/hosts'
                              end
  end

  # The header of the new hostsfile
  #
  # @return [Array]
  #   an array of header comments
  def hostsfile_header
    lines = []
    lines << '#'
    lines << '# This file is managed by the hostsfile gem.'
    lines << '# Editing this file by hand is highly discouraged!'
    lines << '#'
    lines << '# Comments containing an @ sign should not be modified or else'
    lines << '# hostsfile will be unable to guarantee relative priority in'
    lines << '# future runs!'
    lines << '#'
    lines << ''
  end

  # The content that will be written to the hostfile
  #
  # @return [String]
  #   the full contents of the hostfile to be written
  def new_content
    lines = hostsfile_header
    lines += unique_entries.map(&:to_line)
    lines << ''
    lines.join("\n")
  end

  # The current sha of the system hostsfile.
  #
  # @return [String]
  #   the sha of the current hostsfile
  def current_sha
    @current_sha ||= Digest::SHA512.hexdigest(File.read(hostsfile_path))
  end

  # Normalize the given list of elements into a single array with no nil
  # values and no duplicate values.
  #
  # @param [Object] things
  #
  # @return [Array]
  #   a normalized array of things
  def normalize(*things)
    things.flatten.compact.uniq
  end

  # This is a crazy way of ensuring unique objects in an array using a Hash.
  #
  # @return [Array]
  #   the sorted list of entires that are unique
  def unique_entries
    entries = Hash[*@entries.map { |entry| [entry.ip_address, entry] }.flatten].values
    entries.sort_by { |e| [-e.priority.to_i, e.hostname.to_s] }
  end

  # Takes /etc/hosts file contents and builds a flattened entries
  # array so that each IP address has only one line and multiple hostnames
  # are flattened into a list of aliases.
  #
  # @param [Array] contents
  #   Array of lines from /etc/hosts file
  def collect_and_flatten(contents)
    contents.each do |line|
      entry = ::Hostsfile::Entry.parse(line)
      next if entry.nil?

      append(
        ip_address: entry.ip_address,
        hostname:   entry.hostname,
        aliases:    entry.aliases,
        comment:    entry.comment,
        priority:   !entry.calculated_priority? && entry.priority,
      )
    end
  end

  # Removes duplicate hostnames in other files ensuring they are unique
  #
  # @param [Entry] entry
  #   the entry to keep the hostname and aliases from
  #
  # @return [nil]
  def remove_existing_hostnames(entry)
    @entries.delete(entry)
    changed_hostnames = [entry.hostname, entry.aliases].flatten.uniq

    @entries = @entries.collect do |entry|
      entry.hostname = nil if changed_hostnames.include?(entry.hostname)
      entry.aliases  = entry.aliases - changed_hostnames

      if entry.hostname.nil?
        if entry.aliases.empty?
          nil
        else
          entry.hostname = entry.aliases.shift
          entry
        end
      else
        entry
      end
    end.compact

    @entries << entry

    nil
  end
end

end