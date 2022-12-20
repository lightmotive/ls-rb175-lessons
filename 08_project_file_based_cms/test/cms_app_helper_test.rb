require_relative 'test_helper'
require './cms_app_helper'

class CMSAppHelperTest < MiniTest::Test
  def setup
    @obj = Object.new
    @obj.extend(CMSAppHelper)
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
end
