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

  def assert_flash_message(flash_key, expected_messages, session: self.session)
    messages = session[flash_key]
    return assert_equal(expected_messages, messages) if messages.nil?

    explanation = 'The last request should have added the expected message(s) ' \
                  "to an array stored in `session[:#{flash_key}]`."

    case expected_messages
    when String then assert_includes messages, expected_messages, explanation
    when Array then assert_equal messages, expected_messages, explanation
    else
      raise '`expected_messages` must be a String or an Array.'
    end
  end

  def assert_flash_message_rendering(flash_key, expected_messages, in_content)
    case expected_messages
    when String then assert_flash_message_rendering_one(
      flash_key, expected_messages, in_content
    )
    when Array
      expected_messages.each do |message|
        assert_flash_message_rendering_one(flash_key, message, in_content)
      end
    else
      raise '`expected_messages` must be a String or an Array.'
    end
  end

  private

  def assert_flash_message_rendering_one(flash_key, expected_message, in_content)
    assert_includes in_content, %(<div class="flash #{flash_key}">)
    assert_includes in_content, expected_message
  end
end
