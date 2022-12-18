# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/application_controller'

# Test main app controller, including '/' route.
class ApplicationControllerTest < ControllerTestBase
  def app
    OUTER_APP
  end

  def test_get
    get '/'
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    assert_equal "http://example.org#{app_route(:browse)}", last_response['Location']
    assert_empty last_response.body
  end

  def test_get_invalid_route
    get '/nothing_here'
    assert_equal 302, last_response.status
    assert_equal "http://example.org#{app_route(:browse)}", last_response['Location']
  end

  def test_get_invalid_location
    get '/?loc=nada'
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    first_response_location = last_response['Location']
    assert_equal "http://example.org#{app_route(:browse)}", first_response_location
    assert_empty last_response.body
    # Assert flash error message
    get first_response_location
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<div class="flash error">'
    assert_includes last_response.body, '<p>Entry not found.</p>'
    # Assert flash error message disappears on reload
    get first_response_location
    assert_equal 200, last_response.status
    refute_includes last_response.body, '<p>Entry not found.</p>'
  end
end
