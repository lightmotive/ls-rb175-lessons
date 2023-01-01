# frozen_string_literal: true

require_relative 'test_helper'
require './view_helpers/upload'
require_relative 'view_mock'

# For tests in this file.
class ViewMockHelperBrowse < ViewMock
  include ViewHelpers::Upload
end

# Application view helpers
class HelperUploadTest < MiniTest::Test
  def setup
    @view = ViewMockHelperBrowse.new
  end

  def test_upload_action
    location = 'dir1'
    assert_equal @view.app_route(:upload, loc: location),
                 @view.upload_action(location)
  end

  def test_upload_input_accept
    mime_types = Models::ContentEntry.file_types_allowed.values.map do |data|
      data[:content_type]
    end
    assert_equal mime_types.join(', '), @view.upload_input_accept
  end
end
