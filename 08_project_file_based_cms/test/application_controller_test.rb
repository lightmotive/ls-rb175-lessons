# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/application_controller'

# Test main app controller, including '/' route.
class ApplicationControllerTest < ControllerTestBase
  def test_get
    get '/'
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    assert_equal app_route_for_assert(:browse), last_response['Location']
    assert_empty last_response.body
  end

  def test_get_invalid_route_when_authenticated
    get '/nothing_here'
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:browse), last_response['Location']
  end

  def test_get_invalid_location_when_authenticated
    get '/?loc=nada'
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    first_response_location = last_response['Location']
    assert_equal app_route_for_assert(:browse), first_response_location
    assert_empty last_response.body
    expected_error_message = 'That location does not exist. Please browse and try again.'
    assert_flash_message :error, expected_error_message
    # Assert flash error message:
    get first_response_location
    assert_equal 200, last_response.status
    assert_flash_message_rendering :error, expected_error_message, last_response.body
    # Assert flash error was deleted from session:
    assert_nil last_request.session[:error]
  end

  def test_dangerous_location_query_param
    get app_route(:browse), loc: '/../app'
    assert_equal 400, last_response.status
    assert_equal 'Invalid location', last_response.body
  end

  def test_get_index_when_unauthenticated
    simulate_unauthenticated_user
    get app_route(:index)
    assert_nil session[:info]
    assert_equal 200, last_response.status
    assert_includes last_response.body, %(<a href="#{app_route(:login)}">Sign In</a>)
  end

  def test_get_login_when_unauthenticated
    simulate_unauthenticated_user
    get app_route(:login)
    assert_nil session[:info]
    assert_equal 200, last_response.status
    assert_includes last_response.body, %(<button type="submit">Sign In</button>)
  end

  def test_post_logout_when_unauthenticated
    simulate_unauthenticated_user
    post app_route(:logout)
    assert_nil session[:info]
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:index), last_response['Location']
  end

  def test_get_browse_path_when_unauthenticated
    simulate_unauthenticated_user
    # NOTE: content existence check should be delayed until after login
    route = app_route(:browse, loc: '/some_dir/some_file.txt')
    get route
    assert_flash_message :info, 'Please sign in to access that resource.'
    assert_equal route, session[:post_auth_location]
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:login), last_response['Location']
  end

  def test_get_invalid_route_when_unauthenticated
    simulate_unauthenticated_user
    get '/nothing_here'
    assert_nil session[:info]
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:index), last_response['Location']
  end
end
