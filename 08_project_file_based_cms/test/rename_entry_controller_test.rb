# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/rename_entry_controller'

# Test 'app_route(:rename_entry)' routes.
class RenameEntryControllerTest < ControllerTestBase
  def test_get_entry_name_param_not_provided
    get app_route(:rename_entry)
    assert_equal 400, last_response.status
    assert_flash_message_rendering :error,
                                   'The request requires an `entry_name` param.',
                                   last_response.body
  end

  def test_post_entry_name_new_param_not_provided
    create_file(file_name = 'test.txt')
    post app_route(:rename_entry), { entry_name: file_name }
    assert_equal 400, last_response.status
    assert_flash_message_rendering :error,
                                   'The request requires an `entry_name_new` param.',
                                   last_response.body
  end

  def test_get_entry_not_found_in_location
    create_file(file_name = 'test.txt')
    location = 'dir1'
    create_directory(location)
    get app_route(:rename_entry, loc: location), { entry_name: file_name }, env_xhr
    assert_equal 400, last_response.status
    expected_error_msg = 'That entry wasn&#39;t found. Please check and try again.'
    assert_flash_message_rendering :error, expected_error_msg, last_response.body
  end

  # rubocop:disable Metrics/MethodLength
  def test_get_rename_file_with_xhr
    create_file(file_name = 'test.txt')
    get app_route(:rename_entry), { entry_name: file_name }, env_xhr
    assert_equal 200, last_response.status

    rename_action = app_route(
      :rename_entry,
      other_query_params: { entry_name: file_name }
    )
    expected_content = <<~CONTENT.chomp
      <form class="inline rename" action="#{rename_action}" method="post">
        <label for="entry_name_new">Rename:</label>
        <input name="entry_name_new" type="text" placeholder="#{file_name}"
               value="#{file_name}" autofocus>
        <button class="rename" type="submit">Save</button>
        <a class="cancel link-icon" href="/browse">Cancel</a>
      </form>
    CONTENT
    assert_equal expected_content, last_response.body
  end
  # rubocop:enable Metrics/MethodLength

  def test_get_rename_file_without_xhr
    create_directory(location = 'dir1')
    create_file(file_name = 'test.txt', in_loc: location)
    get app_route(:rename_entry, loc: location), { entry_name: file_name }
    assert_equal 200, last_response.status
    rename_action = app_route(:rename_entry,
                              loc: location,
                              other_query_params: { entry_name: file_name })
    assert_includes last_response.body,
                    %(<form class="inline rename" action="#{rename_action}" method="post">)
  end

  # Tests above are ready to run and tweak; tests below to be reviewed...

  def test_post_rename_file_with_xhr
    create_file(current_name = 'test.txt')
    post app_route(:rename_entry), { entry_name: current_name,
                                     entry_name_new: new_name = 'test_renamed.txt' }, env_xhr
    assert_equal 200, last_response.status
    assert_equal app_route(:browse), last_response.body
    assert_flash_message :success, "'#{current_name}' renamed to '#{new_name}'."
    assert_equal :file, content_entry_type(new_name)
    assert_equal :unknown, content_entry_type(current_name)
  end

  def test_post_rename_file_without_xhr
    create_file(current_name = 'test.txt')
    post app_route(:rename_entry), { entry_name: current_name,
                                     entry_name_new: new_name = 'test_renamed.txt' }
    assert_equal 303, last_response.status
    assert_equal app_route_for_assert(:browse), last_response['Location']
    assert_flash_message :success, "'#{current_name}' renamed to '#{new_name}'."
    assert_equal :file, content_entry_type(new_name)
    assert_equal :unknown, content_entry_type(current_name)
  end

  def test_post_rename_with_invalid_name_with_xhr
    create_file(current_name = 'test.txt')
    post app_route(:rename_entry), { entry_name: current_name,
                                     entry_name_new: new_name = 'test+renamed.txt' }, env_xhr
    assert_equal 400, last_response.status
    expected_error_msg = 'Please use only numbers, letters, underscores, and periods for names.'
    assert_flash_message_rendering :error, expected_error_msg, last_response.body
    assert_equal :unknown, content_entry_type(new_name)
    assert_equal :file, content_entry_type(current_name)
  end

  # rubocop:disable Metrics/AbcSize
  def test_post_rename_with_invalid_name_without_xhr
    create_file(current_name = 'test.txt')
    post app_route(:rename_entry), { entry_name: current_name,
                                     entry_name_new: new_name = 'test+renamed.txt' }
    assert_equal 400, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    expected_error_msg = Models::ContentEntry.entry_name_chars_allowed_message
    assert_flash_message_rendering :error, expected_error_msg, last_response.body
    assert_equal :unknown, content_entry_type(new_name)
    assert_equal :file, content_entry_type(current_name)
  end
  # rubocop:enable Metrics/AbcSize

  def test_post_rename_directory_without_xhr
    create_directory(current_name = 'dir1')
    post app_route(:rename_entry), { entry_name: current_name,
                                     entry_name_new: new_name = 'dir_renamed' }
    assert_equal 303, last_response.status
    assert_equal app_route_for_assert(:browse), last_response['Location']
    assert_equal :directory, content_entry_type(new_name)
    assert_equal :unknown, content_entry_type(current_name)
  end

  def test_post_rename_directory_in_subdirectory_with_xhr
    location = 'dir1'
    create_directory("#{location}/dir1.1")
    post app_route(:rename_entry, loc: location), {
      entry_name: current_name = 'dir1.1',
      entry_name_new: new_name = 'dir_renamed'
    }, env_xhr
    assert_equal 200, last_response.status
    assert_equal app_route(:browse, loc: location), last_response.body
    assert_equal :directory, content_entry_type("#{location}/#{new_name}")
    assert_equal :unknown, content_entry_type("#{location}/#{current_name}")
  end

  def test_post_rename_unsafe_path_with_xhr
    create_file(current_name = 'test.txt')
    new_name = '../test_renamed.txt'
    post app_route(:rename_entry), { entry_name: current_name,
                                     entry_name_new: new_name }, env_xhr
    assert_equal 400, last_response.status
    assert_flash_message_rendering :error, 'Invalid location', last_response.body
  end
end
