# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/application_controller'

# Test main app controller, including '/' route.
class ApplicationControllerTest < ControllerTestBase
  def app
    OUTER_APP
  end

  def test_index
    get '/'
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    assert_equal 'http://example.org/browse', last_response['Location']
    assert_empty last_response.body
  end

  def test_invalid_route
    get '/nothing_here'
    assert_equal 302, last_response.status
    assert_equal 'http://example.org/browse', last_response['Location']
  end
end
