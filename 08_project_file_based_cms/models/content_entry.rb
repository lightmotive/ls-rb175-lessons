# frozen_string_literal: true

module Models
  # Content Entry (file system) model with paths relative to application's
  # `./content` directory.
  class ContentEntry
    def initialize(dir_relative:, basename:, path_absolute:)
      @directory = ContentEntry.standardize_dir_relative(dir_relative)
      @name = basename
      @type = ContentEntry.type(path_absolute)
      @path_relative = File.join(directory, name)
    end

    attr_reader :directory, :name, :path_relative, :type

    def actions
      case type
      when :file
        ContentEntry.file_types_allowed.dig(File.extname(path_relative), :actions) || []
      when :directory
        %i[delete]
      else
        []
      end
    end

    class << self
      # Ensure relative directory starts with '/'
      def standardize_dir_relative(dir_relative)
        standardized = dir_relative
        standardized.prepend('/') unless standardized.start_with?('/')
        standardized
      end

      def type(path_absolute)
        return :directory if FileTest.directory?(path_absolute)
        return :file if FileTest.file?(path_absolute)

        :unknown
      end

      def entry_name_chars_allowed_message
        'Please use only numbers, letters, underscores, and periods for names.'
      end

      def dir_name_valid?(dir_name)
        !(dir_name =~ /\A[\w.]+\z/).nil?
      end

      def dir_names_valid?(names)
        names = entry_names_from_user_input(names) if names.is_a?(String)
        names.all?(&method(:dir_name_valid?))
      end

      def file_name_allowed?(path)
        name = File.basename(path)
        !(name =~ /\A[\w.]+\z/).nil?
      end

      def entry_names_from_user_input(input_string)
        input_string.split('/')
      end

      def file_types_allowed
        {
          '.txt' => { content_type: 'text/plain', actions: %i[copy edit delete] },
          '.md' => { content_type: 'text/markdown', actions: %i[copy edit delete] },
          '.png' => { content_type: 'image/png', actions: %i[copy delete] },
          '.jpeg' => { content_type: 'image/jpeg', actions: %i[copy delete] },
          '.jpg' => { content_type: 'image/jpg', actions: %i[copy delete] }
        }
      end

      def file_extension_allowed?(path)
        file_types_allowed.include?(File.extname(path))
      end

      def content_type_allowed?(content_type)
        file_types_allowed.values.any? do |type_data|
          type_data[:content_type] == content_type
        end
      end

      def file_types_allowed_message
        "The following file types can be uploaded: #{
          file_types_allowed.keys.map { |key| key[1..] }.join(', ')}."
      end

      def file_allowed?(path)
        # TODO: implement a more robust and secure file management system that:
        # - Securely verifies actual file content.
        # - Renames files and stores references in a database instead of storing
        #   with provided names in file system.
        # - One library to consider: https://github.com/shrinerb/shrine
        # For now, simply validate file type and name:
        file_extension_allowed?(path) && file_name_allowed?(path)
      end
    end
  end
end
