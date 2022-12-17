# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/delete_controller'

# Test 'APP_ROUTES[:delete]' routes.
class DeleteControllerTest < ControllerTestBase
  def app
    OUTER_APP
  end

  def test_post_file
    file_name = 'deletable.txt'
    create_file(file_name)
    post "#{APP_ROUTES[:delete]}/#{file_name}"
    assert_equal 303, last_response.status
    last_response_location = last_response['Location']
    assert_equal "http://example.org#{APP_ROUTES[:browse]}", last_response_location
    get last_response_location
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<div class="flash success">'
    assert_includes last_response.body, "#{file_name} was deleted."
  end

  def test_post_file_xhr
    file_name = 'deletable.txt'
    create_file(file_name)
    post "#{APP_ROUTES[:delete]}/#{file_name}", nil,
         { 'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest' }
    assert_equal 204, last_response.status
  end

  def test_post_directory
    dir = 'dir1/dir1.1'
    create_directory(dir)
    post "#{APP_ROUTES[:delete]}/#{dir}"
    assert_equal 303, last_response.status
    last_response_location = last_response['Location']
    assert_equal "http://example.org#{APP_ROUTES[:browse]}/dir1", last_response_location
    get last_response_location
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<div class="flash success">'
    assert_includes last_response.body, 'dir1.1 was deleted.'
  end

  def test_post_directory_xhr
    dir = 'dir1/dir1.1'
    create_directory(dir)
    post "#{APP_ROUTES[:delete]}/#{dir}", nil,
         { 'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest' }
    assert_equal 204, last_response.status
  end
end
