# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/new_dir_controller'

# Test 'APP_ROUTES[:edit]' routes.
class NewDirControllerTest < ControllerTestBase
  def app
    OUTER_APP
  end

  def test_get
    get APP_ROUTES[:new_dir]
    assert_includes last_response.body, %(<form action="#{APP_ROUTES[:new_dir]}/" method="post">)
    assert_match %r{<h2>\s*Create a new directory in /\s*</h2>}, last_response.body
  end

  def test_get_subdirectory
    create_directory('dir1')
    get "#{APP_ROUTES[:new_dir]}/dir1"
    assert_includes last_response.body, %(<form action="#{APP_ROUTES[:new_dir]}/dir1" method="post">)
    assert_match %r{<h2>\s*Create a new directory in /dir1\s*</h2>}, last_response.body
  end

  def test_post
    post APP_ROUTES[:new_dir], 'entry_name' => 'dir1'
    assert_equal :directory, content_entry_type('dir1')
    assert_equal 302, last_response.status
    first_response_location = last_response['Location']
    assert_equal "http://example.org#{APP_ROUTES[:browse]}", first_response_location
    get first_response_location
    assert_includes last_response.body, %(<div class="flash success">)
    assert_includes last_response.body, %('dir1' created successfully.)
  end

  def test_post_subdirectory
    create_directory('dir1')
    post "#{APP_ROUTES[:new_dir]}/dir1", 'entry_name' => 'dir1.1'
    assert_equal :directory, content_entry_type('dir1/dir1.1')
    assert_equal "http://example.org#{APP_ROUTES[:browse]}/dir1", last_response['Location']
  end

  def test_post_multiple_subdirectories
    create_directory('dir2/dir2.1')
    post APP_ROUTES[:new_dir], 'entry_name' => 'dir2/dir2.1'
    assert_equal :directory, content_entry_type('dir2/dir2.1')
    assert_equal "http://example.org#{APP_ROUTES[:browse]}", last_response['Location']
  end

  def test_post_invalid_entry_name
    post APP_ROUTES[:new_dir], 'entry_name' => 'dir+3'
    assert_equal :unknown, content_entry_type('dir+3')
    assert_equal 400, last_response.status
    assert_includes last_response.body, %(<div class="flash error">)
    assert_includes last_response.body, %(Please use only numbers, letters, underscores, and periods for names.)
    assert_includes last_response.body, %(<form action="#{APP_ROUTES[:new_dir]}/" method="post">)
    assert_includes last_response.body, %(<input name="entry_name" type="text" value="dir+3">)
  end
end
