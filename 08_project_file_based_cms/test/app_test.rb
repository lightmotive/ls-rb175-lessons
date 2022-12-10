# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative 'test_helper'
require 'rack/test'
require './app'

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
    assert_equal '631', last_response['Content-Length']
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
          <a href="/view/about.txt">about.txt</a>
        </li>
      </ul>
      <ul>
        <li>
          <a href="/view/changes.txt">changes.txt</a>
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
          <a href="/view/history.txt">history.txt</a>
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
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '362', last_response['Content-Length']
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
            <h2>dir1</h2>
      <ul>
        <li>
          <a href="/view/dir1/f1.txt">f1.txt</a>
        </li>
      </ul>

          </main>
        </body>
      </html>
    BODY
    assert_equal expected_body, last_response.body
  end

  def test_browse_dir2_dir21
    get '/browse/dir2/dir2.1'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '376', last_response['Content-Length']
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
            <h2>dir2/dir2.1</h2>
      <ul>
        <li>
          <a href="/view/dir2/dir2.1/f3.txt">f3.txt</a>
        </li>
      </ul>

          </main>
        </body>
      </html>
    BODY
    assert_equal expected_body, last_response.body
  end

  def test_browse_changes_txt
    get '/browse/changes.txt'
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    assert_equal 'http://example.org/view/changes.txt', last_response['Location']
    assert_empty last_response.body
  end

  def test_view_dir1
    get '/view/dir1'
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    assert_equal 'http://example.org/browse/dir1', last_response['Location']
    assert_empty last_response.body
  end

  def test_view_changes_txt
    get '/view/changes.txt'
    assert_equal 200, last_response.status
    assert_equal 'text/plain;charset=utf-8', last_response['Content-Type']
    assert_equal '14', last_response['Content-Length']
    expected_body = <<~BODY.strip
      Coming soon...
    BODY
    assert_equal expected_body, last_response.body
  end

  def test_browse_missing_content
    get '/browse/missing_xyz'
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    assert_equal 'http://example.org/browse', last_response['Location']
    assert_empty last_response.body
    get '/browse'
    assert_equal 200, last_response.status
    flash_error_message = <<~MSG
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
          <div class="flash error">
            <p>/missing_xyz wasn't found.</p>
          </div>
          <main>
    MSG
    assert last_response.body.start_with?(flash_error_message),
           'Ensure the message body shows a flash error containing the ' \
           "previously requested content path that was missing.\n" \
           "Body:\n\n#{last_response.body}"
  end

  def test_view_missing_content
    get '/view/changes'
    assert_equal 302, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_equal '0', last_response['Content-Length']
    assert_equal 'http://example.org/browse', last_response['Location']
    assert_empty last_response.body
  end
end
