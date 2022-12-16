# frozen_string_literal: true

# require 'fileutils'
require 'forwardable'
require_relative 'rack_test_helper'

# All Controller tests should inherit this.
class ControllerTestBase < Minitest::Test
  include Rack::Test::Methods
  extend Forwardable

  def initialize(*args)
    super(*args)

    @content = Models::Content.new
  end

  def_delegators :@content, :create_file
  def_delegator :@content, :path, :path_absolute
  def_delegator :@content, :create_dir, :create_directory
  def_delegator :@content, :entry_type, :content_entry_type

  def setup
    FileUtils.mkdir_p(@content.path)
  end

  def teardown
    FileUtils.rm_rf(@content.path)
  end
end
