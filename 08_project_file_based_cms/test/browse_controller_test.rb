# frozen_string_literal: true

require_relative 'rack_test_helper'
require './controllers/browse_controller'

# Test '/browse' routes.
class BrowseControllerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  def test_browse
    get '/browse'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    expected_body = File.read('./test/expected_body/browse.html')
    assert_equal expected_body, last_response.body
  end

  def test_browse_dir1
    get '/browse/dir1'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<a href="/view/dir1/f1.txt">f1.txt</a>'
  end

  def test_browse_dir2_dir21
    get '/browse/dir2/dir2.1'
    assert_equal 200, last_response.status
    assert_includes last_response.body,
                    '<h2><a href="/browse">home</a>/<a href="/browse/dir2">dir2</a>/dir2.1</h2>'
    assert_includes last_response.body, '<a href="/view/dir2/dir2.1/f3.txt">f3.txt</a>'
  end

  def test_browse_changes_txt
    get '/browse/changes.txt'
    assert_equal 302, last_response.status
    assert_equal 'http://example.org/view/changes.txt', last_response['Location']
  end

  def test_browse_missing_content
    get '/browse/missing_xyz'
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    first_response_location = last_response['Location']
    assert_equal 'http://example.org/browse', first_response_location
    assert_empty last_response.body
    # Assert flash error message
    get first_response_location
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<div class="flash error">'
    assert_includes last_response.body, "<p>/missing_xyz wasn't found.</p>"
    # Assert flash error message disappears on reload
    get first_response_location
    assert_equal 200, last_response.status
    refute_includes last_response.body, "<p>/missing_xyz wasn't found.</p>"
  end
end
