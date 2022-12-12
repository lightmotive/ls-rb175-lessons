# frozen_string_literal: true

require_relative 'rack_test_helper'
require './controllers/edit_controller'

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
  # :nocov:
  # Restore demo files modified during testing
  DEMO_CONTENT_PATHS.each do |path|
    File.write("#{DEMO_CONTENT_ROOT}/#{path}", DEMO_CONTENT_BACKUP[path])
  end
  # :nocov:
end

before_demo_content_modification

MiniTest.after_run { after_demo_content_modification }

# Test '/edit' routes.
class EditControllerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    OUTER_APP
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
