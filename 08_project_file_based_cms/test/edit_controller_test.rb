# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/edit_controller'

# Test 'app_route([:edit])' routes.
class EditControllerTest < ControllerTestBase
  def test_get
    create_file('about.md')

    get app_route(:edit, loc: 'about.md')
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
  end

  def test_post_success
    file_dir_relative = 'dir1'
    file_name = 'f1.txt'
    file_path_relative = "#{file_dir_relative}/#{file_name}"
    file = create_file(file_path_relative, 'About to be updated...')

    post app_route(:edit, loc: file_path_relative), 'file_content' => 'Updated'
    assert_equal 'Updated', File.read(file.path)
    assert_equal 303, last_response.status
    post_response_location = last_response['Location']
    assert_equal "http://example.org#{app_route(:browse, loc: file_dir_relative)}",
                 post_response_location
    # Assert flash success message
    assert_equal "#{file_name} was updated.", last_request.session[:success]
  end

  def test_get_subdirectory
    create_directory('dir1')

    get app_route(:edit, loc: 'dir1')
    assert_equal 302, last_response.status
    first_response_location = last_response['Location']
    assert_equal "http://example.org#{app_route(:browse, loc: 'dir1')}", first_response_location
    # Assert flash error message
    assert_equal 'Editing not allowed.', last_request.session[:error]
  end

  def test_get_missing
    get app_route(:edit, loc: 'nada')
    assert_equal 302, last_response.status
  end
end
