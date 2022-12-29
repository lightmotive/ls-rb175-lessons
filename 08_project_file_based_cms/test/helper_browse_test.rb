# frozen_string_literal: true

require_relative 'test_helper'
require './view_helpers/browse'
require_relative 'view_mock'

# For tests in this file.
class ViewMockHelperBrowse < ViewMock
  include ViewHelpers::Browse
end

# Application view helpers
class HelperBrowseTest < MiniTest::Test
  def setup
    @view = ViewMockHelperBrowse.new
  end

  def test_navigation_path_root
    assert_equal '', @view.navigation_path('/')
  end

  def test_navigation_path_subdir1
    assert_equal %(<a href="#{@view.app_route(:browse)}">home</a>/dir1),
                 @view.navigation_path('/dir1')
  end

  def test_navigation_path_subdir2
    browse_route = @view.app_route(:browse)
    assert_equal %(<a href="#{browse_route}">home</a>/<a href="#{browse_route}?loc=%2Fdir1">dir1</a>/dir1.1),
                 @view.navigation_path('/dir1/dir1.1')
  end

  def test_upload_href
    assert_equal @view.app_route(:upload), @view.upload_href('/')
  end

  def test_uploads_input_accept
    mime_types = Models::ContentEntry.file_types_allowed.values.map do |data|
      data[:content_type]
    end
    assert_equal mime_types.join(', '), @view.uploads_input_accept
  end
end
