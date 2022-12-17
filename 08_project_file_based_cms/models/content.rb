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
      content_path = 'content'
      content_path = File.join('test', content_path) if ENV['RACK_ENV'] == 'test'

      File.join(app_root_path, content_path, path_relative)
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

    # Create file with optional content.
    # Automatically create directories if included.
    def create_file(path_relative, content = '')
      if path_relative =~ %r{\w+/\w+}
        dir = path_relative[0..(path_relative.rindex('/'))]
        create_directory(dir)
      end

      File.open(path(path_relative), 'w') do |file|
        file.write(content)
        file.close
        file
      end
    end

    # Create directory with parents as needed
    def create_directory(path_relative)
      FileUtils.mkdir_p(path(path_relative))
    end
  end
end
