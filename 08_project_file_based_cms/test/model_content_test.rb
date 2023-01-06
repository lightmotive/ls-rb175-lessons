# frozen_string_literal: true

require_relative 'test_helper'
require './models/content'

# ContentEntry model tests.
class ModelContentTest < MiniTest::Test
  def setup
    @content = Models::Content.new
    FileUtils.mkdir_p(@content.path)
  end

  def test_path_input_safe?
    assert_equal false, @content.path_input_safe?('../app.rb')
  end

  def test_file_check
    @content.create_file('test.txt')
    assert_equal true, @content.file?(name: 'test.txt')
  end

  def test_directory_check
    @content.create_directory('dir1')
    assert_equal true, @content.directory?(name: 'dir1')
  end

  def test_entry_with_directory_in_root
    @content.create_directory('dir1')
    entry = @content.entry(name: 'dir1')
    assert_equal true, entry.directory?
  end

  def test_entry_with_file_in_loc
    @content.create_file('dir1/test.txt')
    entry = @content.entry(name: 'test.txt', in_loc: 'dir1')
    assert_equal true, entry.file?
  end

  def test_rename_file
    @content.create_file('test.txt')
    @content.rename_entry('test.txt', 'test_renamed.txt')
    assert_equal true, @content.file?(name: 'test_renamed.txt')
    assert_equal false, @content.exist?('test.txt')
  end

  def test_rename_directory
    @content.create_directory('dir1')
    @content.rename_entry('dir1', 'dir_renamed')
    assert_equal true, @content.directory?(name: 'dir_renamed')
    assert_equal false, @content.exist?('dir1')
  end

  def teardown
    FileUtils.rm_rf(@content.path)
  end
end
