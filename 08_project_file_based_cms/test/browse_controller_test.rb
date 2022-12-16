# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/browse_controller'

require 'pry'

# Test APP_ROUTES[:browse] routes.
class BrowseControllerTest < ControllerTestBase
  def app
    OUTER_APP
  end

  def test_get
    create_file('about.md')
    create_file('changes.txt')
    create_directory('dir1')

    get APP_ROUTES[:browse]
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    expected_body = File.read('./test/expected_body/browse.html')
    assert_equal expected_body, last_response.body
  end

  def test_get_subdirectory_without_files
    dir = 'dir1'
    create_directory(dir)

    get "#{APP_ROUTES[:browse]}/#{dir}"
    assert_equal 200, last_response.status
    new_dir_link = %(<a href="#{APP_ROUTES[:new_dir]}/#{dir}">[New Directory]</a>)
    new_file_link = %(<a href="#{APP_ROUTES[:new_file]}/#{dir}">[New File]</a>)
    assert_includes last_response.body, %(#{new_dir_link} #{new_file_link})
  end

  def test_get_first_subdirectory
    dir = 'dir1'
    create_file("#{dir}/f1.txt")

    get "#{APP_ROUTES[:browse]}/#{dir}"
    assert_equal 200, last_response.status
    file_link = %(<a href="#{APP_ROUTES[:view]}/#{dir}/f1.txt">f1.txt</a>)
    assert_includes last_response.body, file_link
  end

  def test_get_subdirectory_second_level
    dirs = 'dir1/dir1.1'
    create_file("#{dirs}/f3.txt")

    get "#{APP_ROUTES[:browse]}/#{dirs}"
    assert_equal 200, last_response.status
    home_link = %(<a href="#{APP_ROUTES[:browse]}">home</a>)
    dir2_link = %(<a href="#{APP_ROUTES[:browse]}/dir1">dir1</a>)
    assert_includes last_response.body, %(<h2>#{home_link}/#{dir2_link}/dir1.1</h2>)
    file_link = %(<a href="#{APP_ROUTES[:view]}/#{dirs}/f3.txt">f3.txt</a>)
    assert_includes last_response.body, file_link
    new_dir_link = %(<a href="#{APP_ROUTES[:new_dir]}/#{dirs}">[New Directory]</a>)
    new_file_link = %(<a href="#{APP_ROUTES[:new_file]}/#{dirs}">[New File]</a>)
    assert_includes last_response.body, %(#{new_dir_link} #{new_file_link})
  end

  def test_get_file
    create_file('changes.txt')

    get "#{APP_ROUTES[:browse]}/changes.txt"
    assert_equal 302, last_response.status
    assert_equal "http://example.org#{APP_ROUTES[:view]}/changes.txt", last_response['Location']
  end

  def test_get_missing_content
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
