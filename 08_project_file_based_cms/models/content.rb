# frozen_string_literal: true

require_relative 'content_entry'

module Models
  # Content access
  class Content
    attr_reader :app_root_path

    def initialize
      # rubocop:disable Style/ExpandPathArguments
      # - Reason: `File.expand_path(__dir__)` translates symbolic links to real
      #   paths, which we don't want in this program.
      @app_root_path = File.expand_path('../../', __FILE__)
      # rubocop:enable Style/ExpandPathArguments
    end

    # => Absolute path
    def path(path_relative = '/')
      path = 'content'
      path = File.join('test', path) if ENV['RACK_ENV'] == 'test'

      File.join(app_root_path, path, path_relative)
    end

    def entry_type(path_relative)
      ContentEntry.type(path(path_relative))
    end

    def entries(dir_relative = '/')
      Dir.each_child(path(dir_relative)).map do |entry_name|
        ContentEntry.new(
          dir_relative: dir_relative,
          basename: entry_name,
          path_absolute: path(File.join(dir_relative, entry_name))
        )
      end
    end
  end
end
