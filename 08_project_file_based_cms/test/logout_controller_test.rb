# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/logout_controller'

# Test 'app_route([:logout])' routes.
class LogoutControllerTest < ControllerTestBase
  def test_get
    get app_route(:logout)
    assert_nil last_request.session.fetch(:username, nil)
    assert_flash_message :success, 'You have been signed out.', last_request.session
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:index), last_response['Location']
  end
end
