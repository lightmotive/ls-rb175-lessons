# frozen_string_literal: true

require_relative 'rack_test_helper'
require './controllers/application_controller'

# Test main app controller, including '/' route.
class ApplicationControllerTest < Minitest::Test
  include Rack::Test::Methods

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
end
