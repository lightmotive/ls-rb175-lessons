# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/browse_controller'

# Test 'app_route(:browse)' routes.
class BrowseControllerTest < ControllerTestBase
  def test_get
    create_file('about.md')
    create_file('changes.txt')
    create_file('beautiful.png')
    create_directory('dir1')

    get app_route(:browse)
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, %(<title>Browse Neato CMS</title>)
    assert_includes last_response.body, %(<script src="/javascripts/browse_controller.js"></script>)
    assert_action_links(last_response.body)
  end

  def test_get_subdirectory_without_files
    create_directory(dir = 'dir1')

    get app_route(:browse, loc: dir)
    assert_equal 200, last_response.status
    assert_action_links(last_response.body, route_loc: dir)
  end

  def test_get_first_subdirectory
    create_directory(dir = 'dir1')
    create_file(file_name = 'f1.txt', in_loc: dir)

    get app_route(:browse, loc: dir)
    assert_equal 200, last_response.status
    file_link = %(<a href="#{app_route(:view, loc: "#{dir}/#{file_name}")}">f1.txt</a>)
    assert_includes last_response.body, file_link
    assert_action_links(last_response.body, route_loc: dir)
  end

  def test_get_subdirectory_second_level
    create_directory(location = 'dir1/dir1.1')
    create_file(file_name = 'f3.txt', in_loc: location)

    get app_route(:browse, loc: location)
    assert_equal 200, last_response.status
    file_link = %(<a href="#{
      app_route(:view, loc: "#{location}/#{file_name}")}">#{file_name}</a>)
    assert_includes last_response.body, file_link
    assert_action_links(last_response.body, route_loc: location)
  end

  def test_get_file
    create_file('changes.txt')

    get app_route(:browse, loc: 'changes.txt')
    assert_equal 302, last_response.status
    assert_equal app_route_for_assert(:view, loc: 'changes.txt'), last_response['Location']
  end

  def test_get_missing_content
    get app_route(:browse, loc: 'nada')
    assert_equal 302, last_response.status
  end

  private

  def assert_action_links(in_content, route_loc: '/')
    new_entry_form_content = %(<form action="#{app_route(:new_entry, loc: route_loc)}" method="post">)
    assert_includes in_content, new_entry_form_content

    upload_form_content = String.new(%(<form action="#{app_route(:upload, loc: route_loc)}" ))
    upload_form_content += %(enctype="multipart/form-data" method="post">)
    assert_includes in_content, upload_form_content
  end
end
