# frozen_string_literal: true

# TODO: set the following env vars using environment management systems:
# - For dev and test: https://github.com/bkeepers/dotenv
# - For production, use host framework's secure environment management system.
ENV['RACK_ENV'] = 'test'

require 'forwardable'

# Include to support Content access within tests.
module ContentTestMod
  extend Forwardable

  def initialize(*args)
    super(*args)

    @content = Models::Content.new
  end

  def_delegators :@content, :app_root_path, :create_file, :create_directory
  def_delegator :@content, :path, :content_path
  def_delegator :@content, :entry_type, :content_entry_type

  def setup
    FileUtils.mkdir_p(@content.path)
  end

  def teardown
    FileUtils.rm_rf(@content.path)
  end
end
