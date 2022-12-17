# frozen_string_literal: true

require_relative 'test_helper'
require './view_helpers/application_helper'

# Application view helpers
class ApplicationHelperTest < MiniTest::Test
  def setup
    @obj = Object.new
    @obj.extend(ViewHelpers::ApplicationHelper)
  end

  def test_app_route
    assert_equal '/browse', @obj.app_route(:browse)
    assert_equal '/', @obj.app_route(:index)
  end

  def test_app_route_with_path
    assert_equal '/view/subpath1/subpath2', @obj.app_route(:view, path: 'subpath1/subpath2')
  end

  def test_app_route_with_location
    assert_equal '/new/dir?loc=%2Fdir1%2Ftest.txt', @obj.app_route(:new_dir, loc: 'dir1/test.txt')
  end

  def test_app_route_with_path_and_location
    assert_equal '/new/dir/subpath?loc=%2Ftest.txt', @obj.app_route(:new_dir, path: 'subpath', loc: 'test.txt')
  end

  def test_session_flash_messages_content_array_size2
    content_array = ['Test message 1', 'Test message 2']
    expected_content = <<~CONTENT
      <ul>
      <li>#{content_array.join("</li>\n<li>")}</li>
      </ul>
    CONTENT
    assert_equal expected_content, @obj.session_flash_messages(content_array)
  end

  def test_session_flash_messages_content_array_size1
    content = @obj.session_flash_messages(['Test single message'])
    assert_equal '<p>Test single message</p>', content
  end

  def test_session_flash_messages_content_array_empty
    content = @obj.session_flash_messages(['Test flash message'])
    assert_equal '<p>Test flash message</p>', content
  end

  def test_session_flash_messages_content_string_empty
    content = @obj.session_flash_messages(['Test flash message'])
    assert_equal '<p>Test flash message</p>', content
  end

  def test_session_flash_messages_content_string
    content = @obj.session_flash_messages('Test flash message')
    assert_equal '<p>Test flash message</p>', content
  end

  def test_session_flash_messages_content_invalid
    assert_raises(RuntimeError) do
      @obj.session_flash_messages({})
    end
  end

  def test_session_flash_messages_content_nil
    assert_equal '', @obj.session_flash_messages(nil)
  end
end
