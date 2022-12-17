# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/new_file_controller'

# Test 'APP_ROUTES[:edit]' routes.
class NewFileControllerTest < ControllerTestBase
  def app
    OUTER_APP
  end

  def test_get
    get APP_ROUTES[:new_file]
    assert_includes last_response.body, %(<form action="#{APP_ROUTES[:new_file]}" method="post">)
    assert_match %r{<h2>\s*Create a new file in /\s*</h2>}, last_response.body
  end

  def test_get_subdirectory
    create_directory('dir1')
    get "#{APP_ROUTES[:new_file]}/dir1"
    assert_includes last_response.body, %(<form action="#{APP_ROUTES[:new_file]}/dir1" method="post">)
    assert_match %r{<h2>\s*Create a new file in /dir1\s*</h2>}, last_response.body
  end

  def test_post
    post APP_ROUTES[:new_file], 'entry_name' => 'something_new.txt'
    assert_equal :file, content_entry_type('something_new.txt')
    assert_equal 302, last_response.status
    first_response_location = last_response['Location']
    assert_equal "http://example.org#{APP_ROUTES[:browse]}", first_response_location
    get first_response_location
    assert_includes last_response.body, %(<div class="flash success">)
    assert_includes last_response.body, %('something_new.txt' created successfully.)
  end

  def test_post_subdirectory
    create_directory('dir1')
    post "#{APP_ROUTES[:new_file]}/dir1", 'entry_name' => 'something_new.md'
    assert_equal :file, content_entry_type('dir1/something_new.md')
    assert_equal "http://example.org#{APP_ROUTES[:browse]}/dir1", last_response['Location']
  end

  def test_post_invalid_entry_name
    post APP_ROUTES[:new_file], 'entry_name' => 'something+invalid.txt'
    assert_equal :unknown, content_entry_type('something+invalid.txt')
    assert_equal 400, last_response.status
    assert_includes last_response.body, %(<div class="flash error">)
    assert_includes last_response.body, %(Please use only numbers, letters, underscores, and periods for names.)
    assert_includes last_response.body, %(<form action="#{APP_ROUTES[:new_file]}" method="post">)
    assert_includes last_response.body, %(<input name="entry_name" type="text" value="something+invalid.txt">)
  end
end
