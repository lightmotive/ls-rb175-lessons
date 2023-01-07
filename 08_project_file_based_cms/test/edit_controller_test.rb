# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/edit_controller'

# Test 'app_route([:edit])' routes.
class EditControllerTest < ControllerTestBase
  def test_get
    create_file(file_name = 'about.md')

    get app_route(:edit, loc: file_name)
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
  end

  def test_post_success
    create_directory(file_dir_relative = 'dir1')
    file = create_file(file_name = 'f1.txt', 'About to be updated...', in_loc: file_dir_relative)
    file_path_relative = "#{file_dir_relative}/#{file_name}"

    post app_route(:edit, loc: file_path_relative), 'file_content' => 'Updated'
    assert_equal 'Updated', File.read(file.path)
    assert_equal 303, last_response.status
    post_response_location = last_response['Location']
    assert_equal app_route_for_assert(:browse, loc: file_dir_relative),
                 post_response_location
    assert_flash_message :success, "#{file_name} was updated."
  end

  def test_get_subdirectory
    create_directory(location = 'dir1')

    get app_route(:edit, loc: location)
    assert_equal 302, last_response.status
    first_response_location = last_response['Location']
    assert_equal app_route_for_assert(:browse, loc: location), first_response_location
    # Assert flash error message
    assert_flash_message :error, 'Editing not allowed.'
  end

  def test_get_missing
    get app_route(:edit, loc: 'nada')
    assert_equal 302, last_response.status
  end
end
