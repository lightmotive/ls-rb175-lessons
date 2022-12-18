# frozen_string_literal: true

# require 'fileutils'
require 'forwardable'
require_relative 'rack_test_helper'

# All Controller tests should inherit this.
class ControllerTestBase < Minitest::Test
  include Rack::Test::Methods
  include ViewHelpers::ApplicationHelper
  extend Forwardable

  def initialize(*args)
    super(*args)

    @content = Models::Content.new
  end

  def_delegators :@content, :create_file, :create_directory
  def_delegator :@content, :path, :content_path
  def_delegator :@content, :entry_type, :content_entry_type

  def app
    OUTER_APP
  end

  def setup
    FileUtils.mkdir_p(@content.path)
  end

  def teardown
    FileUtils.rm_rf(@content.path)
  end
end
