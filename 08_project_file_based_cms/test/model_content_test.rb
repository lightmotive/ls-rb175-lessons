# frozen_string_literal: true

require_relative 'test_helper'
require './models/content'

# ContentEntry model tests.
class ModelContentTest < MiniTest::Test
  def setup
    @content = Models::Content.new
    FileUtils.mkdir_p(@content.path)
  end

  def test_file_check
    @content.create_file('test.txt')
    assert_equal true, @content.file?('test.txt')
  end

  def test_directory_check
    @content.create_directory('dir1')
    assert_equal true, @content.directory?('dir1')
  end

  def teardown
    FileUtils.rm_rf(@content.path)
  end
end
