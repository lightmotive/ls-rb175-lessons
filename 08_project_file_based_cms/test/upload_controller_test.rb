# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/upload_controller'

require 'pry'

# Test 'app_route([:edit])' routes.
class UploadControllerTest < ControllerTestBase
  def setup
    super

    @string_ios = []
  end

  def new_string_io
    @string_ios << StringIO.open
    @string_ios.last
  end

  def mock_upload(content, content_type, filename)
    strio = new_string_io
    strio.write(content)
    Rack::Test::UploadedFile.new(strio, content_type, original_filename: filename)
  end

  def mock_params_uploads(mock_uploads_args)
    uploads = case mock_uploads_args.first
              when Array
                mock_uploads_args.map { |args| mock_upload(*args) }
              else
                [mock_upload(*mock_uploads_args)]
              end

    { 'uploads' => uploads }
  end

  def test_post_single_file
    filename = 'upload.txt'
    params = mock_params_uploads(['Upload content.', 'text/plain', filename])
    post app_route(:upload), params
    assert_equal :file, content_entry_type(filename)
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:browse), last_response['Location']
    assert_flash_message :success, "Successfully uploaded '#{filename}'."
  end

  def test_post_multiple_files
    filenames = ['upload1.txt', 'upload4.md']
    params = mock_params_uploads(
      [
        ['Upload content for U1.', 'text/plain', filenames[0]],
        ['Upload content for U2.', 'text/markdown', filenames[1]]
      ]
    )
    post app_route(:upload), params
    filenames.each { |name| assert_equal :file, content_entry_type(name) }
    assert_flash_message :success, "Successfully uploaded '#{filenames[0]}' and '#{filenames[1]}'."
  end

  def test_post_to_subdirectory
    directory = 'dir1'
    create_directory(directory)
    file_path = File.join(app_root_path, '/content/fasted.jpeg')
    upload = Rack::Test::UploadedFile.new(file_path, 'image/jpeg')
    post app_route(:upload, loc: directory), { 'uploads' => [upload] }
    assert_equal :file, content_entry_type("#{directory}/fasted.jpeg")
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:browse, loc: directory), last_response['Location']
  end

  def test_post_invalid_file_type
    filename = 'upload.xyz'
    params = mock_params_uploads(['Upload content.', 'other/xyz', filename])
    post app_route(:upload), params
    assert_equal :unknown, content_entry_type(filename)
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:browse), last_response['Location']
    expected_error = "'#{filename}' was not allowed. #{Models::ContentEntry.file_types_allowed_message}"
    assert_flash_message :error, expected_error
  end

  def test_post_invalid_file_name_and_type
    filename = 'upload+1.xyz'
    params = mock_params_uploads(['Upload content.', 'other/xyz', filename])
    post app_route(:upload), params
    assert_equal :unknown, content_entry_type(filename)
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:browse), last_response['Location']
    explanations = [
      Models::ContentEntry.entry_name_chars_allowed_message,
      Models::ContentEntry.file_types_allowed_message
    ]
    expected_error = "'#{filename}' was not allowed. #{explanations.join(' ')}"
    assert_flash_message :error, expected_error
  end

  def teardown
    super

    @string_ios.each(&:close)
  end
end
