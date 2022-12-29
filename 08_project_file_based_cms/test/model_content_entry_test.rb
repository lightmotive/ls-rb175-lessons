# frozen_string_literal: true

require_relative 'test_helper'
require './models/content_entry'

# ContentEntry model tests.
class ModelContentEntryTest < MiniTest::Test
  def test_file_name_valid_with_invalid_name
    assert_equal false, Models::ContentEntry.file_name_allowed?('file+1.txt')
  end

  def test_file_name_valid_with_valid_name
    assert_equal true, Models::ContentEntry.file_name_allowed?('file_1.txt')
  end

  def test_file_allowed_with_valid_name_and_disallowed_extension
    assert_equal false, Models::ContentEntry.file_allowed?('file_1.html')
  end

  def test_allowed_files
    file_types = Models::ContentEntry.file_types_allowed
    expected_allowed_filepaths = file_types.keys.map do |key|
      "something.#{key}"
    end

    expected_allowed_filepaths.each do |path|
      assert_equal true, Models::ContentEntry.file_allowed?(path)
    end
  end
end
