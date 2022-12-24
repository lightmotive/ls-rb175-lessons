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
end
