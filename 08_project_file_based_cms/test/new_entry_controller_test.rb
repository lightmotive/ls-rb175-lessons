# frozen_string_literal: true

require_relative 'controller_test_base'

# Test 'app_route([:new_entry])' routes.
class NewEntryControllerTest < ControllerTestBase
  def test_post_new_directory
    post app_route(:new_entry), { 'new_entry_type' => 'directory',
                                  'new_entry_name' => 'dir1' }
    assert_equal :directory, content_entry_type('dir1')
    assert_equal 303, last_response.status
    assert_equal app_route_for_assert(:browse), last_response['Location']
    assert_flash_message :success, "'dir1' created successfully."
  end

  def test_post_new_file
    filename = 'something_new.txt'
    post app_route(:new_entry), { 'new_entry_type' => 'file',
                                  'new_entry_name' => filename }
    assert_equal :file, content_entry_type(filename)
    assert_equal 303, last_response.status
    assert_equal app_route_for_assert(:browse), last_response['Location']
    assert_flash_message :success, "'#{filename}' created successfully."
  end

  def test_post_in_subdirectory
    create_directory('dir1')
    post app_route(:new_entry, loc: 'dir1'), { 'new_entry_type' => 'directory',
                                               'new_entry_name' => 'dir1.1' }
    assert_equal :directory, content_entry_type('dir1/dir1.1')
    assert_equal app_route_for_assert(:browse, loc: 'dir1'), last_response['Location']
  end

  def test_post_nested_subdirectories
    post app_route(:new_entry), { 'new_entry_type' => 'directory',
                                  'new_entry_name' => 'dir1/dir1.1' }
    assert_equal :directory, content_entry_type('dir1/dir1.1')
    assert_equal app_route_for_assert(:browse), last_response['Location']
  end

  def test_post_invalid_directory_name
    post app_route(:new_entry), { 'new_entry_type' => 'directory',
                                  'new_entry_name' => 'dir+3' }
    assert_equal :unknown, content_entry_type('dir+3')
    assert_equal 400, last_response.status
    assert_flash_message_rendering(
      :error,
      ['Please use only numbers, letters, underscores, and periods for names.',
       'Use &#39;/&#39; to separate entries.'],
      last_response.body
    )
  end

  def test_post_invalid_file_name
    post app_route(:new_entry), { 'new_entry_type' => 'file',
                                  'new_entry_name' => 'something%invalid.txt' }
    assert_equal :unknown, content_entry_type('something%invalid.txt')
    assert_equal 400, last_response.status
    assert_flash_message_rendering(
      :error,
      'Please use only numbers, letters, underscores, and periods for names.',
      last_response.body
    )
  end
end
