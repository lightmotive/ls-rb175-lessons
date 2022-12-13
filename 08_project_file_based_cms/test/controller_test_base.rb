# frozen_string_literal: true

# require 'fileutils'
require_relative 'rack_test_helper'

# All Controller tests should inherit this.
class ControllerTestBase < Minitest::Test
  include Rack::Test::Methods

  def setup
    @test_content_path = Models::Content.new.path
    FileUtils.mkdir_p(@test_content_path)
  end

  def path_absolute(content_relative_path)
    File.join(@test_content_path, content_relative_path)
  end

  # Create test dir (for testing empty directories)
  def create_directory(content_relative_path)
    abs_path = path_absolute(content_relative_path)
    FileUtils.mkdir_p(abs_path)
  end

  # Create test file
  def create_file(content_relative_path, content = '')
    if content_relative_path.include?('/')
      dir = content_relative_path[0..(content_relative_path.rindex('/'))]
      create_directory(dir)
    end

    File.open(path_absolute(content_relative_path), 'w') do |file|
      file.write(content)
      file.close
      file
    end
  end

  def teardown
    FileUtils.rm_rf(@test_content_path)
  end
end
