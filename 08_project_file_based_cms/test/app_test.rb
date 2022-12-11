# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative 'test_helper'
require 'rack/test'
require './app'

DEMO_CONTENT_ROOT = './content'
DEMO_CONTENT_PATHS = ['dir1/f1.txt'].freeze
DEMO_CONTENT_BACKUP = Hash.new { |h, k| h[k] = String.new }

def before_demo_content_modification
  # Backup demo files that will be edited during testing
  DEMO_CONTENT_PATHS.each do |path|
    DEMO_CONTENT_BACKUP[path] = File.read("#{DEMO_CONTENT_ROOT}/#{path}")
  end
end

def after_demo_content_modification
  # Restore demo files modified during testing
  DEMO_CONTENT_PATHS.each do |path|
    File.write("#{DEMO_CONTENT_ROOT}/#{path}", DEMO_CONTENT_BACKUP[path])
  end
end

before_demo_content_modification

MiniTest.after_run { after_demo_content_modification }

# Test main app
class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get '/'
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    assert_equal 'http://example.org/browse', last_response['Location']
    assert_empty last_response.body
  end

  def test_browse
    get '/browse'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    expected_body = <<~BODY
      <!doctype html>
      <html lang="en-US">
        <head>
          <title>Public CMS</title>
          <meta charset="UTF-8">
          <link rel="stylesheet" href="/stylesheets/application.css">
        </head>
        <body>
          <header>
            <h1>CMS</h1>
          </header>
          <main>
            <h2></h2>
      <ul>
        <li>
          <a href="/view/about.md">about.md</a> [ <a href="/edit/about.md">Edit</a> ]
        </li>
      </ul>
      <ul>
        <li>
          <a href="/view/changes.txt">changes.txt</a> [ <a href="/edit/changes.txt">Edit</a> ]
        </li>
      </ul>
      <ul>
        <li>
          <a href="/browse/dir1">dir1</a>
        </li>
      </ul>
      <ul>
        <li>
          <a href="/browse/dir2">dir2</a>
        </li>
      </ul>
      <ul>
        <li>
          <a href="/view/history.txt">history.txt</a> [ <a href="/edit/history.txt">Edit</a> ]
        </li>
      </ul>

          </main>
        </body>
      </html>
    BODY
    assert_equal expected_body, last_response.body
  end

  def test_browse_dir1
    get '/browse/dir1'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<a href="/view/dir1/f1.txt">f1.txt</a>'
  end

  def test_browse_dir2_dir21
    get '/browse/dir2/dir2.1'
    assert_equal 200, last_response.status
    assert_includes last_response.body,
                    '<h2><a href="/browse">home</a>/<a href="/browse/dir2">dir2</a>/dir2.1</h2>'
    assert_includes last_response.body, '<a href="/view/dir2/dir2.1/f3.txt">f3.txt</a>'
  end

  def test_browse_changes_txt
    get '/browse/changes.txt'
    assert_equal 302, last_response.status
    assert_equal 'http://example.org/view/changes.txt', last_response['Location']
  end

  def test_view_dir1
    get '/view/dir1'
    assert_equal 302, last_response.status
    assert_equal 'http://example.org/browse/dir1', last_response['Location']
  end

  def test_view_changes_txt
    get '/view/changes.txt'
    assert_equal 200, last_response.status
    assert_equal 'text/plain;charset=utf-8', last_response['Content-Type']
    assert_equal 'Coming soon...', last_response.body
  end

  def test_view_dir2_dir21_f3_txt
    get '/view/dir2/dir2.1/f3.txt'
    assert_equal 200, last_response.status
    assert_equal 'text/plain;charset=utf-8', last_response['Content-Type']
    assert_equal 'Test file in dir2.1.', last_response.body
  end

  def test_browse_missing_content
    get '/browse/missing_xyz'
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    first_response_location = last_response['Location']
    assert_equal 'http://example.org/browse', first_response_location
    assert_empty last_response.body
    # Assert flash error message
    get first_response_location
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<div class="flash error">'
    assert_includes last_response.body, "<p>/missing_xyz wasn't found.</p>"
    # Assert flash error message disappears on reload
    get first_response_location
    assert_equal 200, last_response.status
    refute_includes last_response.body, "<p>/missing_xyz wasn't found.</p>"
  end

  def test_view_missing_content
    get '/view/nada'
    assert_equal 302, last_response.status
    assert_equal 'http://example.org/browse', last_response['Location']
    assert_empty last_response.body
  end

  def test_view_markdown_as_html
    get '/view/about.md'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    expected_body = <<~BODY
      <h2>Ruby is...</h2>

      <p>A dynamic, open-source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write.</p>
    BODY
    assert_equal expected_body, last_response.body
  end

  def test_edit
    get '/edit/about.md'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
  end

  def test_edit_save
    content_path = DEMO_CONTENT_PATHS.first
    file_dir = File.dirname(content_path)
    file_name = File.basename(content_path)
    file_path = "#{DEMO_CONTENT_ROOT}/#{content_path}"

    post "/edit/#{content_path}", 'file_content' => 'Updated'
    assert_equal 'Updated', File.read(file_path)
    assert_equal 303, last_response.status
    post_response_location = last_response['Location']
    assert_equal "http://example.org/browse/#{file_dir}", post_response_location
    # Assert flash success message
    flash_success_message = "#{file_name} has been updated."
    get post_response_location
    assert_includes last_response.body, '<div class="flash success">'
    assert_includes last_response.body, flash_success_message
    # Assert flash success message disappears on reload
    get post_response_location
    refute_includes last_response.body, flash_success_message
  end

  def test_edit_directory
    get '/edit/dir1'
    assert_equal 302, last_response.status
    last_response_location = last_response['Location']
    assert_equal 'http://example.org/browse/dir1', last_response_location
    # Assert flash error message
    get last_response_location
    assert_includes last_response.body, '<div class="flash error">'
    assert_includes last_response.body, 'Editing not allowed.'
  end
end
