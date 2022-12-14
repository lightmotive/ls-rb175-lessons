# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/browse_controller'

require 'pry'

# Test APP_ROUTES[:browse] routes.
class BrowseControllerTest < ControllerTestBase
  def app
    OUTER_APP
  end

  def test_browse
    create_file('about.md')
    create_file('changes.txt')
    create_directory('dir1')

    get APP_ROUTES[:browse]
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    expected_body = File.read('./test/expected_body/browse.html')
    assert_equal expected_body, last_response.body
  end

  def test_browse_dir1
    create_file('dir1/f1.txt')

    get "#{APP_ROUTES[:browse]}/dir1"
    assert_equal 200, last_response.status
    assert_includes last_response.body,
                    %(<a href="#{APP_ROUTES[:view]}/dir1/f1.txt">f1.txt</a>)
  end

  def test_browse_dir2_dir21
    create_file('dir2/dir2.1/f3.txt')

    get "#{APP_ROUTES[:browse]}/dir2/dir2.1"
    assert_equal 200, last_response.status
    assert_includes last_response.body,
                    %(<h2><a href="#{APP_ROUTES[:browse]}">home</a>/<a href="#{APP_ROUTES[:browse]}/dir2">dir2</a>/dir2.1</h2>)
    assert_includes last_response.body,
                    %(<a href="#{APP_ROUTES[:view]}/dir2/dir2.1/f3.txt">f3.txt</a>)
  end

  def test_browse_changes_txt
    create_file('changes.txt')

    get "#{APP_ROUTES[:browse]}/changes.txt"
    assert_equal 302, last_response.status
    assert_equal "http://example.org#{APP_ROUTES[:view]}/changes.txt", last_response['Location']
  end

  def test_browse_missing_content
    get "#{APP_ROUTES[:browse]}/missing_abc/xyz"
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    first_response_location = last_response['Location']
    assert_equal "http://example.org#{APP_ROUTES[:browse]}", first_response_location
    assert_empty last_response.body
    # Assert flash error message
    get first_response_location
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<div class="flash error">'
    assert_includes last_response.body, "<p>/missing_abc/xyz wasn't found.</p>"
    # Assert flash error message disappears on reload
    get first_response_location
    assert_equal 200, last_response.status
    refute_includes last_response.body, "<p>/missing_abc/xyz wasn't found.</p>"
  end
end
