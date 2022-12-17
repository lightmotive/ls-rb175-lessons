# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/edit_controller'

# Test 'APP_ROUTES[:edit]' routes.
class EditControllerTest < ControllerTestBase
  def app
    OUTER_APP
  end

  def test_get
    create_file('about.md')

    get "#{APP_ROUTES[:edit]}/about.md"
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
  end

  def test_post_success
    file_dir_relative = 'dir1'
    file_name = 'f1.txt'
    file_path_relative = "#{file_dir_relative}/#{file_name}"
    file = create_file(file_path_relative, 'About to be updated...')

    post "#{APP_ROUTES[:edit]}/#{file_path_relative}", 'file_content' => 'Updated'
    assert_equal 'Updated', File.read(file.path)
    assert_equal 303, last_response.status
    post_response_location = last_response['Location']
    assert_equal "http://example.org#{APP_ROUTES[:browse]}/#{file_dir_relative}",
                 post_response_location
    # Assert flash success message
    flash_success_message = "#{file_name} was updated."
    get post_response_location
    assert_includes last_response.body, '<div class="flash success">'
    assert_includes last_response.body, flash_success_message
    # Assert flash success message disappears on reload
    get post_response_location
    refute_includes last_response.body, flash_success_message
  end

  def test_get_subdirectory
    create_directory('dir1')

    get "#{APP_ROUTES[:edit]}/dir1"
    assert_equal 302, last_response.status
    last_response_location = last_response['Location']
    assert_equal "http://example.org#{APP_ROUTES[:browse]}/dir1", last_response_location
    # Assert flash error message
    get last_response_location
    assert_includes last_response.body, '<div class="flash error">'
    assert_includes last_response.body, 'Editing not allowed.'
  end

  def test_get_missing
    get "#{APP_ROUTES[:edit]}/nada"
    assert_equal 302, last_response.status
    last_response_location = last_response['Location']
    assert_equal "http://example.org#{APP_ROUTES[:browse]}", last_response_location
    # Assert flash error message
    get last_response_location
    assert_includes last_response.body, '<div class="flash error">'
    assert_includes last_response.body, 'Entry not found.'
  end
end
