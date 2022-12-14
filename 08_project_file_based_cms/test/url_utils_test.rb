# frozen_string_literal: true

require_relative 'test_helper'
require './app/url_utils'

class URLUtilsTest < MiniTest::Test
  def test_join_components_empty
    assert_equal '', URLUtils.join_paths('')
    assert_equal '', URLUtils.join_paths(nil)
  end

  def test_join_components_one
    assert_equal 'start', URLUtils.join_paths('start')
  end

  def test_join_components_leading_separator_component
    assert_equal '/', URLUtils.join_paths('/')
    assert_equal '/some/path', URLUtils.join_paths('/', 'some/path')
  end

  def test_join_components_one_with_leading_separator
    assert_equal '/start', URLUtils.join_paths('/start')
    assert_equal '/start', URLUtils.join_paths('//start')
  end

  def test_join_components_two
    assert_equal 'start/2', URLUtils.join_paths('start', '2')
  end

  def test_join_components_multiple
    assert_equal 'start/2/3', URLUtils.join_paths('start', '2', '3')
  end

  def test_join_components_multiple_with_leading_separator
    assert_equal '/start/2/3', URLUtils.join_paths('/start', '2', '3')
  end

  def test_join_components_with_leading_separators
    assert_equal '/start/2/3', URLUtils.join_paths('/start', '/2', '/3')
  end

  def test_join_components_with_trailing_separators
    assert_equal 'start/2/3/', URLUtils.join_paths('start/', '2/', '3/')
  end

  def test_join_components_with_adjacent_separators
    assert_equal 'start/2/3/', URLUtils.join_paths('start/', '/2/', '/3/')
    assert_equal 'start/2/3/', URLUtils.join_paths('start/', '/2/', '/3//')
  end

  def test_join_components_with_empty_subpaths
    assert_equal 'start', URLUtils.join_paths('start', '', '')
    assert_equal '/start', URLUtils.join_paths('/start', '', '')
    assert_equal '/start', URLUtils.join_paths('/start/', '', '')
  end

  def test_join_components_with_only_separators
    assert_equal '/', URLUtils.join_paths('/')
    assert_equal '/', URLUtils.join_paths('/', '/')
    assert_equal '/', URLUtils.join_paths('/', '//')
  end

  def test_paths_normalized
    normalizer = URLUtils::PathNormalizer.new(['/', '/2', '/3/', '4', '/5', '6'])
    assert_equal ['/', '2', '3', '4', '5', '6'], normalizer.paths_normalized
    normalizer = URLUtils::PathNormalizer.new(['/', '/2', '/3/', '4/'])
    assert_equal ['/', '2', '3', '4/'], normalizer.paths_normalized
  end
end
