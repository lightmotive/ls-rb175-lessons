# frozen_string_literal: true

require_relative 'content_error'

module Models
  # Content Entry (file system) model with paths relative to application's
  # `./content` directory.
  class ContentEntry
    def initialize(dir_relative:, basename:, path_absolute:)
      @directory = ContentEntry.standardize_loc_relative(dir_relative)
      @name = basename
      @type = ContentEntry.type(path_absolute)
      @path_relative = File.join(directory, name)
    end

    attr_reader :directory, :name, :path_relative, :type

    def type_supported?
      %i[directory file].include?(@type)
    end

    def file?
      type == :file
    end

    def directory?
      type == :directory
    end

    def action_allowed?(action)
      actions_allowed.include?(action)
    end

    def actions_allowed
      case type
      when :file
        ContentEntry.file_types_allowed.dig(File.extname(path_relative), :actions) || []
      when :directory
        %i[view rename delete]
      else
        []
      end
    end

    class << self
      # Ensure relative directory starts with '/'
      def standardize_loc_relative(loc_relative)
        standardized = String.new(loc_relative)
        standardized += '/' unless standardized.start_with?('/')
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

      def separate_entries_message
        "Use '/' to separate entries."
      end

      def dir_name_valid?(dir_name)
        !(dir_name =~ /\A[\w.]+\z/).nil?
      end

      def dir_names_valid?(names)
        names = entry_names_from_user_input(names) if names.is_a?(String)
        names.all?(&method(:dir_name_valid?))
      end

      def dir_names_allowed_message
        "#{ContentEntry.entry_name_chars_allowed_message} #{
         ContentEntry.separate_entries_message}"
      end

      def file_name_allowed?(path)
        name = File.basename(path)
        !(name =~ /\A[\w.]+\z/).nil?
      end

      def entry_names_from_user_input(input_string)
        input_string.split('/')
      end

      def actions
        %i[view rename copy edit delete]
      end

      def actions_except(*exclude)
        actions - exclude
      end

      def file_types_allowed
        {
          '.txt' => { content_type: 'text/plain', actions: },
          '.md' => { content_type: 'text/markdown', actions: },
          '.png' => { content_type: 'image/png', actions: actions_except(:edit) },
          '.jpeg' => { content_type: 'image/jpeg', actions: actions_except(:edit) },
          '.jpg' => { content_type: 'image/jpg', actions: actions_except(:edit) }
        }
      end

      def file_type(extname)
        file_types_allowed.fetch(extname, nil)
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
        # - Securely verifies that file content matches extension.
        # - Renames files and stores references in a database instead of storing
        #   with provided names in file system. That would also loosen name
        #   restrictions.
        # - One library to consider: https://github.com/shrinerb/shrine
        # - ** For now, simply validate file type and name: **
        file_extension_allowed?(path) && file_name_allowed?(path)
      end

      def validate_names(name, type:)
        # TODO: consider implementing polymorphic sequence processing here to
        # iterate through validation steps defined in separate classes.
        # Recommended only if content validation becomes complex enough to
        # warrant that abstraction.

        error = ContentError.new

        case type
        when :directory
          error << dir_names_allowed_message unless dir_names_valid?(name)
        when :file
          error << entry_name_chars_allowed_message unless file_name_allowed?(name)
          error << file_types_allowed_message unless file_extension_allowed?(name)
        end

        raise error if error.any?
      end
    end
  end
end
