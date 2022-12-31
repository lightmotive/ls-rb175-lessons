# frozen_string_literal: true

require_relative 'test_helper_rack'
require_relative 'content_test_mod'
require './cms_app_helper'

# All Controller tests should inherit this.
class ControllerTestBase < MiniTest::Test
  include Rack::Test::Methods
  include ContentTestMod
  include CMSAppHelper

  def app
    OUTER_APP
  end

  def setup
    super
    simulate_authenticated_user(username: 'admin')
  end

  def session
    last_request.session
    # Alt: last_request.env['rack.session']
  end

  def configure_session(hash)
    env 'rack.session', hash
  end

  def simulate_authenticated_user(username: 'admin')
    configure_session({ username: })
  end

  def simulate_unauthenticated_user
    configure_session({ username: nil })
  end

  def app_route_for_assert(...)
    "http://example.org#{app_route(...)}"
  end

  def assert_flash_message(flash_key, expected_message, session: self.session)
    failure_msgs = session[flash_key]
    return assert_equal(expected_message, failure_msgs) if failure_msgs.nil?

    assert_includes failure_msgs,
                    expected_message,
                    'The last request should have added the expected message to ' \
                    "to an array stored in `session[:#{flash_key}]`"
  end

  def assert_flash_message_rendering(flash_key, message, in_content)
    assert_includes in_content, %(<div class="flash #{flash_key}">)
    assert_includes in_content, Rack::Utils.escape_html(message)
  end
end
