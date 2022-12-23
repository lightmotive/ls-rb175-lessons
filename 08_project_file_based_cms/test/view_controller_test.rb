# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/view_controller'

# Test 'app_route([:view])' routes.
class ViewControllerTest < ControllerTestBase
  def test_get_subdirectory
    create_directory('dir1')

    get app_route(:view, loc: 'dir1')
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:browse, loc: 'dir1'), last_response['Location']
  end

  def test_get_file
    create_file('changes.txt', 'Coming soon...')

    get app_route(:view, loc: 'changes.txt')
    assert_equal 200, last_response.status
    assert_equal 'text/plain;charset=utf-8', last_response['Content-Type']
    assert_equal 'Coming soon...', last_response.body
  end

  def test_get_file_in_subdirectory
    create_file('dir2/dir2.1/f3.txt', 'Test file in dir2.1.')

    get app_route(:view, loc: 'dir2/dir2.1/f3.txt')
    assert_equal 200, last_response.status
    assert_equal 'text/plain;charset=utf-8', last_response['Content-Type']
    assert_equal 'Test file in dir2.1.', last_response.body
  end

  def test_get_missing_content
    get app_route(:view, loc: 'nada')
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:browse), last_response['Location']
    assert_empty last_response.body
  end

  def test_get_markdown_file
    create_file('about.md', "## Ruby is...\n")

    get app_route(:view, loc: 'about.md')
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, "<h2>Ruby is...</h2>\n"
  end
end
