# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/delete_controller'

# Test 'app_route([:delete])' routes.
class DeleteControllerTest < ControllerTestBase
  def test_post_file
    file_name = 'deletable.txt'
    create_file(file_name)
    post app_route(:delete, loc: file_name)
    assert_equal 303, last_response.status
    assert_equal app_route_for_assert(:browse), last_response['Location']
    assert_flash_message :success, "#{file_name} was deleted."
  end

  def test_post_file_xhr
    file_name = 'deletable.txt'
    create_file(file_name)
    post app_route(:delete, loc: file_name), nil, env_xhr
    assert_equal 204, last_response.status
  end

  def test_post_directory
    dir = 'dir1/dir1.1'
    create_directory(dir)
    post app_route(:delete, loc: dir)
    assert_equal 303, last_response.status
    assert_equal app_route_for_assert(:browse, loc: 'dir1'), last_response['Location']
    assert_flash_message :success, 'dir1.1 was deleted.'
  end

  def test_post_directory_xhr
    dir = 'dir1/dir1.1'
    create_directory(dir)
    post app_route(:delete, loc: dir), nil, env_xhr
    assert_equal 204, last_response.status
  end

  def test_post_missing_directory
    post app_route(:delete, loc: 'nada')
    assert_equal 302, last_response.status
  end
end
