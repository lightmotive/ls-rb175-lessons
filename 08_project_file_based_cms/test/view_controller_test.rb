# frozen_string_literal: true

require_relative 'controller_test_base'
require './controllers/view_controller'

# Test '/view' routes.
class ViewControllerTest < ControllerTestBase
  def app
    OUTER_APP
  end

  def test_view_dir1
    create_directory('dir1')

    get '/view/dir1'
    assert_equal 302, last_response.status
    assert_equal 'http://example.org/browse/dir1', last_response['Location']
  end

  def test_view_changes_txt
    create_file('changes.txt', 'Coming soon...')

    get '/view/changes.txt'
    assert_equal 200, last_response.status
    assert_equal 'text/plain;charset=utf-8', last_response['Content-Type']
    assert_equal 'Coming soon...', last_response.body
  end

  def test_view_dir2_dir21_f3_txt
    create_file('dir2/dir2.1/f3.txt', 'Test file in dir2.1.')

    get '/view/dir2/dir2.1/f3.txt'
    assert_equal 200, last_response.status
    assert_equal 'text/plain;charset=utf-8', last_response['Content-Type']
    assert_equal 'Test file in dir2.1.', last_response.body
  end

  def test_view_missing_content
    get '/view/nada'
    assert_equal 302, last_response.status
    assert_equal 'http://example.org/browse', last_response['Location']
    assert_empty last_response.body
  end

  def test_view_markdown_as_html
    create_file('about.md', "## Ruby is...\n")

    get '/view/about.md'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal "<h2>Ruby is...</h2>\n", last_response.body
  end
end
