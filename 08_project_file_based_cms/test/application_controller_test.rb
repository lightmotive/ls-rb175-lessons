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
    assert_equal "http://example.org#{app_route(:browse)}", last_response['Location']
    assert_empty last_response.body
  end

  def test_get_invalid_route_when_authenticated
    get '/nothing_here'
    assert_equal 302, last_response.status
    assert_equal "http://example.org#{app_route(:browse)}", last_response['Location']
  end

  def test_get_invalid_location_when_authenticated
    get '/?loc=nada'
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    first_response_location = last_response['Location']
    assert_equal "http://example.org#{app_route(:browse)}", first_response_location
    assert_empty last_response.body
    assert_flash_message :error, 'Entry not found.', last_request.session
    # Assert flash error message:
    get first_response_location
    assert_equal 200, last_response.status
    assert_flash_message_rendering(:error, 'Entry not found.', last_response.body)
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
    assert_equal 200, last_response.status
    assert_includes last_response.body, %(<a href="#{app_route(:login)}">Sign In</a>)
  end

  def test_get_login_when_unauthenticated
    simulate_unauthenticated_user
    get app_route(:login)
    assert_equal 200, last_response.status
    assert_includes last_response.body, %(<button type="submit">Sign In</button>)
  end

  def test_post_logout_when_unauthenticated
    simulate_unauthenticated_user
    post app_route(:logout)
    assert_equal 302, last_response.status
    assert_equal app_route_for_assertion(:index), last_response['Location']
  end

  def test_get_browse_path_when_unauthenticated
    simulate_unauthenticated_user
    # NOTE: content existence check should be delayed until after login
    route = app_route(:browse, loc: '/some_dir/some_file.txt')
    get route
    assert_equal route, last_request.session[:post_auth_location]
    assert_equal 302, last_response.status
    assert_equal app_route_for_assertion(:login), last_response['Location']
  end

  def test_get_invalid_route_when_unauthenticated
    simulate_unauthenticated_user
    get '/nothing_here'
    assert_equal 302, last_response.status
    assert_equal app_route_for_assertion(:index), last_response['Location']
  end
end
