# frozen_string_literal: true

# require 'fileutils'
require 'forwardable'
require_relative 'rack_test_helper'
require './cms_app_helper'

# All Controller tests should inherit this.
class ControllerTestBase < Minitest::Test
  include Rack::Test::Methods
  include CMSAppHelper
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
    simulate_authenticated_user
  end

  def simulate_authenticated_user
    env 'rack.session', { username: ENV.fetch('TEST_AUTHENTICATED', nil) }
  end

  def simulate_unauthenticated_user
    env 'rack.session', { username: nil }
  end

  def app_route_for_assert(...)
    "http://example.org#{app_route(...)}"
  end

  def assert_flash_message(flash_class, expected_message, session)
    assert_equal expected_message,
                 session[flash_class],
                 "The last action should have set session[:#{flash_class}] to the expected message."
  end

  def assert_flash_message_rendering(flash_class, message, in_content)
    assert_includes in_content, %(<div class="flash #{flash_class}">)
    assert_includes in_content, Rack::Utils.escape_html(message)
  end

  def teardown
    FileUtils.rm_rf(@content.path)
  end
end
