# frozen_string_literal: true

require_relative 'test_helper'
require './view_helpers/application_helper'

class AppMock
  include ViewHelpers::ApplicationHelper

  def initialize
    @session = {}
  end

  attr_reader :session

  def flash_message(flash_key, content)
    ViewHelpers::ApplicationHelper.flash_message(flash_key, content, store: session)
  end
end

# Application view helpers
class ApplicationHelperTest < MiniTest::Test
  def setup
    @obj = AppMock.new
  end

  def test_flash_message_append_string
    session = {}
    message = 'Test success message.'

    ViewHelpers::ApplicationHelper.flash_message(
      :success, message, store: session
    )

    assert_equal [message], session[:success]
  end

  def test_flash_message_append_array
    session = {}
    errors = ['Test error 1.', 'Test error 2.']

    ViewHelpers::ApplicationHelper.flash_message(
      :error, errors, store: session
    )

    assert_equal errors, session[:error]
  end

  def test_flash_message_append_third_message
    first_message = 'Message one.'
    second_message = 'Message two.'
    third_message = 'Message three.'
    session = { info: [first_message, second_message] }

    ViewHelpers::ApplicationHelper.flash_message(
      :info, third_message, store: session
    )

    assert_equal [first_message, second_message, third_message], session[:info]
  end

  def test_flash_message_append_two_more_messages
    first_message = 'Message one.'
    second_message = 'Message two.'
    third_message = 'Message three.'
    fourth_message = 'Message four.'
    session = { success: [first_message, second_message] }

    ViewHelpers::ApplicationHelper.flash_message(
      :success, [third_message, fourth_message], store: session
    )

    assert_equal [first_message, second_message, third_message, fourth_message], session[:success]
  end

  def test_render_flash_messages_none
    assert_equal '', @obj.render_flash_messages(:test)
  end

  def test_render_flash_messages_single
    message = 'Test single message'
    @obj.flash_message :test, message
    assert_equal "<p>#{message}</p>", @obj.render_flash_messages(:test)
  end

  def test_render_flash_messages_multiple
    content_array = ['Test message 1', 'Test message 2']
    @obj.flash_message :test, content_array
    expected_content = <<~CONTENT
      <ul>
      <li>#{content_array.join("</li>\n<li>")}</li>
      </ul>
    CONTENT
    assert_equal expected_content, @obj.render_flash_messages(:test)
  end
end
