# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'view_mock'

# For tests in this file.
class ViewMockHelperApp < ViewMock
  def flash_message(flash_key, content)
    ViewHelpers::App.flash_message(flash_key, content, store: session)
  end
end

# Application view helpers
class HelperAppTest < MiniTest::Test
  def setup
    @view = ViewMockHelperApp.new
  end

  def test_flash_message_append_string
    message = 'Test success message.'
    @view.flash_message(:success, message)
    assert_equal [message], @view.session[:success]
  end

  def test_flash_message_append_array
    errors = ['Test error 1.', 'Test error 2.']
    @view.flash_message(:error, errors)
    assert_equal errors, @view.session[:error]
  end

  def test_flash_message_append_third_message
    message_set1 = ['Message one.', 'Message two.']
    third_message = 'Message three.'

    @view.flash_message(:info, message_set1)
    @view.flash_message(:info, third_message)

    assert_equal (message_set1 << third_message), @view.session[:info]
  end

  def test_flash_message_append_two_more_messages
    message_set1 = ['Message one.', 'Message two.']
    message_set2 = ['Message three.', 'Message four.']

    @view.flash_message(:success, message_set1)
    @view.flash_message(:success, message_set2)

    assert_equal message_set1.concat(message_set2), @view.session[:success]
  end

  def test_render_flash_message_no_content
    assert_nil @view.render_flash_message(:test)
  end

  def test_render_flash_message_single
    message = 'Test single message'
    @view.flash_message :test, message

    expected_content = <<~CONTENT.chomp
      <div class="flash test">
        <p>#{message}</p>
      </div>
    CONTENT
    assert_equal expected_content, @view.render_flash_message(:test)
    assert_nil @view.session[:test],
               'Default options for method call above should clear stored messages after render.'
  end

  def test_render_flash_message_multiple
    content_array = ['Test message 1', 'Test message 2']
    @view.flash_message :test, content_array
    expected_content = <<~CONTENT.chomp
      <div class="flash test">
        <ul>
          <li>Test message 1</li>
          <li>Test message 2</li>
        </ul>
      </div>
    CONTENT
    assert_equal expected_content, @view.render_flash_message(:test)
  end

  def test_render_flash_message_without_delete_after_render
    message = 'Test single message'
    @view.flash_message :test, message
    @view.render_flash_message(:test, delete_after_rendering: false)
    assert_equal [message], @view.session[:test],
                 '`delete_after_rendering` option above should have retained stored messages.'
  end

  def test_render_flash_messages
    message1 = 'Test message 1'
    @view.flash_message :success, message1
    message2 = 'Test message 2'
    @view.flash_message :error, message2

    expected_content = <<~CONTENT.chomp
      <div class="flash success">
        <p>#{message1}</p>
      </div>
      <div class="flash error">
        <p>#{message2}</p>
      </div>
    CONTENT
    assert_equal expected_content, @view.render_flash_messages
  end
end
