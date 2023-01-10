# frozen_string_literal: true

require 'forwardable'

# Provide convenient Models::Content usage.
module ContentAccessor
  extend Forwardable

  def initialize_content_accessor
    @content = Models::Content.new
  end

  def_delegators :@content, :create_file, :create_directory, :rename_entry
  def_delegator :@content, :absolute_path, :content_absolute_path
  def_delegator :@content, :entry_type, :content_entry_type
  def_delegator :@content, :entry_type_supported?, :content_entry_type_supported?
  def_delegator :@content, :directory?, :content_directory?
  def_delegator :@content, :file?, :content_file?
  def_delegator :@content, :entry, :content_entry
  def_delegator :@content, :entries, :content_entries
end
