# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/new_dir_controller'

# Test 'app_route([:edit])' routes.
class NewDirControllerTest < ControllerTestBase
  def test_get
    get app_route(:new_dir)
    assert_includes last_response.body, %(<form action="#{app_route(:new_dir)}" method="post">)
    assert_match %r{<h2>\s*Create a new directory in /\s*</h2>}, last_response.body
  end

  def test_get_subdirectory
    create_directory('dir1')
    get app_route(:new_dir, loc: 'dir1')
    assert_includes last_response.body, %(<form action="#{app_route(:new_dir, loc: 'dir1')}" method="post">)
    assert_match %r{<h2>\s*Create a new directory in /dir1\s*</h2>}, last_response.body
  end

  def test_post
    post app_route(:new_dir), 'entry_name' => 'dir1'
    assert_equal :directory, content_entry_type('dir1')
    assert_equal 303, last_response.status
    first_response_location = last_response['Location']
    assert_equal "http://example.org#{app_route(:browse)}", first_response_location
    assert_flash_message :success, "'dir1' created successfully.", last_request.session
  end

  def test_post_subdirectory
    create_directory('dir1')
    post app_route(:new_dir, loc: 'dir1'), 'entry_name' => 'dir1.1'
    assert_equal :directory, content_entry_type('dir1/dir1.1')
    assert_equal "http://example.org#{app_route(:browse, loc: 'dir1')}", last_response['Location']
  end

  def test_post_multiple_subdirectories
    create_directory('dir2/dir2.1')
    post app_route(:new_dir), 'entry_name' => 'dir2/dir2.1'
    assert_equal :directory, content_entry_type('dir2/dir2.1')
    assert_equal "http://example.org#{app_route(:browse)}", last_response['Location']
  end

  def test_post_invalid_entry_name
    post app_route(:new_dir), 'entry_name' => 'dir+3'
    assert_equal :unknown, content_entry_type('dir+3')
    assert_equal 400, last_response.status
    assert_flash_message_rendering(
      :error, 'Please use only numbers, letters, underscores, and periods for names.',
      last_response.body
    )
    assert_includes last_response.body, %(<form action="#{app_route(:new_dir)}" method="post">)
    assert_includes last_response.body, %(<input name="entry_name" type="text" value="dir+3">)
  end
end
