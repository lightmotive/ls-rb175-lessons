# frozen_string_literal: true

require_relative 'content_entry'
require_relative 'content_path_error'

module Models
  # Content access
  class Content
    def initialize
      # rubocop:disable Style/ExpandPathArguments
      # - Reason: `File.expand_path(__dir__)` translates symbolic links to real
      #   paths, which we don't want in this program.
      @app_root_path = File.expand_path('../../', __FILE__)
      # rubocop:enable Style/ExpandPathArguments
    end

    attr_reader :app_root_path

    # Scan path for security issues
    def path_input_safe?(path)
      return false if path&.include?('..')

      true
    end

    def exist?(path_relative)
      FileTest.exist?(path(path_relative))
    end

    # => Absolute path
    def path(path_relative = '/')
      raise ContentPathError, 'Invalid location' unless path_input_safe?(path_relative)

      content_path = 'content'
      content_path = File.join('test', content_path) if ENV['RACK_ENV'] == 'test'

      File.join(app_root_path, content_path, path_relative)
    end

    def entry_type(path_relative)
      ContentEntry.type(path(path_relative))
    end

    def entry_type_supported?(name:, in_loc: '/')
      entry(name:, in_loc:).type_supported?
    end

    def file?(name:, in_loc: '/')
      entry(name:, in_loc:).file?
    end

    def directory?(name:, in_loc: '/')
      entry(name:, in_loc:).directory?
    end

    def entries(in_loc = '/')
      Dir.each_child(path(in_loc)).map do |name|
        entry(name:, in_loc:)
      end
    end

    def entry(name:, in_loc: '/')
      ContentEntry.new(
        dir_relative: in_loc, basename: name,
        path_absolute: path(File.join(in_loc, name))
      )
    end

    def entry_from_path(path_relative)
      in_loc = File.dirname(path_relative)
      in_loc = '/' if in_loc == '.'
      name = File.basename(path_relative)
      entry(name:, in_loc:)
    end

    # Create file with optional content.
    # Automatically create directories if included.
    def create_file(path_relative, content = '')
      validate_entry_name(File.basename(path_relative), type: :file)

      create_directory(File.dirname(path_relative)) if path_relative =~ %r{\w+/\w+}

      File.open(path(path_relative), 'w') do |file|
        file.write(content)
        file.close
        file
      end
    end

    # Copy existing file from an absolute path (can be external) to the
    # specified relative path.
    def copy_external(from_absolute, to_relative)
      raise ContentPathError unless path_input_safe?(from_absolute)

      FileUtils.cp(from_absolute, path(to_relative))
    end

    # Create directory with parents as needed
    def create_directory(path_relative)
      validate_entry_name(path_relative, type: :directory)

      FileUtils.mkdir_p(path(path_relative))
    end

    def edit_file(path_relative, content)
      File.write(path(path_relative), content)
    end

    def rename_entry(name:, new_name:, in_loc: '/')
      current_entry = entry(name:, in_loc:)

      validate_entry_name(new_name, type: current_entry.type)

      File.rename(
        path(current_entry.path_relative),
        path(File.join(current_entry.directory, new_name))
      )
    end

    def delete_entry(path_relative)
      case entry_type(path_relative)
      when :file then FileUtils.rm(path(path_relative))
      when :directory then FileUtils.remove_dir(path(path_relative))
      end
    end

    private

    def validate_entry_name(name, type:)
      case type
      when :directory
        raise ContentPathError, dir_names_invalid_message unless ContentEntry.dir_names_valid?(name)
      when :file
        unless ContentEntry.file_name_allowed?(name)
          raise ContentPathError, ContentEntry.entry_name_chars_allowed_message
        end
      end
    end

    def dir_names_invalid_message
      "#{ContentEntry.entry_name_chars_allowed_message} #{
       ContentEntry.separate_entries_message}"
    end
  end
end
