# frozen_string_literal: true

require_relative 'test_helper'
require './app/app_routes'

class AppRoutesTest < MiniTest::Test
  def setup
    @obj = Object.new
    @obj.extend(AppRoutes)
  end

  def test_location_query_param_is_standardized
    assert_equal({}, AppRoutes.location_query_param('/'))
    assert_equal({}, AppRoutes.location_query_param(''))
    assert_equal({ loc: '/dir' }, AppRoutes.location_query_param('dir'))
    assert_equal({ loc: '/dir' }, AppRoutes.location_query_param('/dir'))
  end

  def test_public_routes
    AppRoutes::PUBLIC_ROUTES.each do |route|
      assert_equal true, @obj.route_public?(route)
    end
  end

  def test_app_route
    assert_equal '/browse', @obj.app_route(:browse)
    assert_equal '/', @obj.app_route(:index)
  end

  def test_app_route_with_path
    assert_equal '/view/subpath1/subpath2',
                 @obj.app_route(:view, path: 'subpath1/subpath2')
  end

  def test_app_route_with_location
    assert_equal '/new-entry?loc=%2Fdir1%2Ftest.txt',
                 @obj.app_route(:new_entry, loc: 'dir1/test.txt')
  end

  def test_app_route_with_path_and_location
    assert_equal '/new-entry/subpath?loc=%2Ftest.txt',
                 @obj.app_route(:new_entry, path: 'subpath', loc: 'test.txt')
  end
end
