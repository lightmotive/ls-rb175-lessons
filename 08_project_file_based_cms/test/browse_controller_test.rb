# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/browse_controller'

require 'pry'

# Test 'app_route(:browse)' routes.
class BrowseControllerTest < ControllerTestBase
  def app
    OUTER_APP
  end

  def test_get
    create_file('about.md')
    create_file('changes.txt')
    create_directory('dir1')

    get app_route(:browse)
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    expected_body = File.read('./test/expected_body/browse.html')
    assert_equal expected_body, last_response.body
  end

  def test_get_subdirectory_without_files
    dir = 'dir1'
    create_directory(dir)

    get app_route(:browse, loc: dir)
    assert_equal 200, last_response.status
    new_dir_link = %(<a href="#{app_route(:new_dir, loc: dir)}">[New Directory]</a>)
    new_file_link = %(<a href="#{app_route(:new_file, loc: dir)}">[New File]</a>)
    assert_includes last_response.body, %(#{new_dir_link} #{new_file_link})
  end

  def test_get_first_subdirectory
    dir = 'dir1'
    file_name = 'f1.txt'
    create_file("#{dir}/#{file_name}")

    get app_route(:browse, loc: dir)
    assert_equal 200, last_response.status
    file_link = %(<a href="#{app_route(:view, loc: "#{dir}/#{file_name}")}">f1.txt</a>)
    assert_includes last_response.body, file_link
  end

  def test_get_subdirectory_second_level
    location = 'dir1/dir1.1'
    file_name = 'f3.txt'
    create_file("#{location}/#{file_name}")

    get app_route(:browse, loc: location)
    assert_equal 200, last_response.status
    home_link = %(<a href="#{app_route(:browse)}">home</a>)
    dir1_link = %(<a href="#{app_route(:browse, loc: 'dir1')}">dir1</a>)
    assert_includes last_response.body, %(<h2>#{home_link}/#{dir1_link}/dir1.1</h2>)
    file_link = %(<a href="#{app_route(:view, loc: "#{location}/#{file_name}")}">#{file_name}</a>)
    assert_includes last_response.body, file_link
    new_dir_link = %(<a href="#{app_route(:new_dir, loc: location)}">[New Directory]</a>)
    new_file_link = %(<a href="#{app_route(:new_file, loc: location)}">[New File]</a>)
    assert_includes last_response.body, %(#{new_dir_link} #{new_file_link})
  end

  def test_get_file
    create_file('changes.txt')

    get app_route(:browse, loc: 'changes.txt')
    assert_equal 302, last_response.status
    assert_equal "http://example.org#{app_route(:view, loc: 'changes.txt')}", last_response['Location']
  end

  def test_get_missing_content
    get app_route(:browse, loc: 'nada')
    assert_equal 302, last_response.status
  end
end
