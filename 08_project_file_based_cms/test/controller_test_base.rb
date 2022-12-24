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

  def session
    last_request.session
    # Alt: last_request.env['rack.session']
  end

  def configure_session(hash)
    env 'rack.session', hash
  end

  def simulate_authenticated_user(username: ENV.fetch('TEST_USER_ADMIN', nil))
    configure_session({ username: })
  end

  def simulate_unauthenticated_user
    configure_session({ username: nil })
  end

  def app_route_for_assert(...)
    "http://example.org#{app_route(...)}"
  end

  def assert_flash_message(flash_key, expected_message, session: self.session)
    assert_includes session[flash_key],
                    expected_message,
                    'The last request should have added the expected message to ' \
                    "to an array stored in `session[:#{flash_key}]`"
  end

  def assert_flash_message_rendering(flash_key, message, in_content)
    assert_includes in_content, %(<div class="flash #{flash_key}">)
    assert_includes in_content, Rack::Utils.escape_html(message)
  end

  def teardown
    FileUtils.rm_rf(@content.path)
  end
end
