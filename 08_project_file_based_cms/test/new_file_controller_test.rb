# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/new_file_controller'

# Test 'app_route([:edit])' routes.
class NewFileControllerTest < ControllerTestBase
  def test_get
    get app_route(:new_file)
    assert_includes last_response.body, %(<form action="#{app_route(:new_file)}" method="post">)
    assert_match %r{<h2>\s*Create a new file in /\s*</h2>}, last_response.body
  end

  def test_get_subdirectory
    create_directory('dir1')
    get app_route(:new_file, loc: 'dir1')
    assert_includes last_response.body, %(<form action="#{app_route(:new_file, loc: 'dir1')}" method="post">)
    assert_match %r{<h2>\s*Create a new file in /dir1\s*</h2>}, last_response.body
  end

  def test_post
    post app_route(:new_file), 'entry_name' => 'something_new.txt'
    assert_equal :file, content_entry_type('something_new.txt')
    assert_equal 303, last_response.status
    first_response_location = last_response['Location']
    assert_equal "http://example.org#{app_route(:browse)}", first_response_location
    assert_equal "'something_new.txt' created successfully.", last_request.session[:success]
  end

  def test_post_in_subdirectory
    create_directory('dir1')
    post app_route(:new_file, loc: 'dir1'), 'entry_name' => 'something_new.md'
    assert_equal :file, content_entry_type('dir1/something_new.md')
    assert_equal "http://example.org#{app_route(:browse, loc: 'dir1')}", last_response['Location']
  end

  def test_post_invalid_entry_name
    post app_route(:new_file), 'entry_name' => 'something+invalid.txt'
    assert_equal :unknown, content_entry_type('something+invalid.txt')
    assert_equal 400, last_response.status
    assert_flash_message_rendering(
      :error, 'Please use only numbers, letters, underscores, and periods for names.',
      last_response.body
    )
    assert_includes last_response.body, %(<form action="#{app_route(:new_file)}" method="post">)
    assert_includes last_response.body, %(<input name="entry_name" type="text" value="something+invalid.txt">)
  end
end
