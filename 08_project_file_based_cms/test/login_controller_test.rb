# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/login_controller'

# Test 'app_route([:login])' routes.
class LoginControllerTest < ControllerTestBase
  def test_get
    simulate_unauthenticated_user
    get app_route(:login)
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<h2>Sign In</h2>'
  end

  def test_get_when_authenticated
    get app_route(:login)
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:browse), last_response['Location']
  end

  def test_post_valid_credentials
    post app_route(:login), {
      username: ENV.fetch('TEST_OR_DEV_USER_USERNAME', nil),
      password: ENV.fetch('TEST_OR_DEV_USER_PASSWORD', nil)
    }
    assert_equal 302, last_response.status
    assert_flash_message :success, 'Welcome!', last_request.session
    assert_equal app_route_for_assert(:browse), last_response['Location']
  end

  def test_post_valid_credentials_after_unauthenticated_browse
    simulate_unauthenticated_user
    # Check that user is authenticated and redirected to browse route
    browse_location = '/some_dir/some_file.txt'
    get_route = app_route(:browse, loc: browse_location)
    get get_route
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:login), last_response['Location']
    get app_route(:login)
    assert_equal 200, last_response.status
    post app_route(:login), {
      username: ENV.fetch('TEST_OR_DEV_USER_USERNAME', nil),
      password: ENV.fetch('TEST_OR_DEV_USER_PASSWORD', nil)
    }
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:browse, loc: browse_location),
                 last_response['Location']
  end

  def test_post_invalid_credentials
    simulate_unauthenticated_user
    # Check that user is authenticated and redirected to browse route
    post app_route(:login), {
      username: 'wrong-username',
      password: 'wrong-password'
    }
    assert_equal 200, last_response.status
    assert_includes last_response.body, %(<h2>Sign In</h2>)
    assert_flash_message_rendering(
      :error,
      'Invalid credentials. Please check your username and password.',
      last_response.body
    )
  end
end
