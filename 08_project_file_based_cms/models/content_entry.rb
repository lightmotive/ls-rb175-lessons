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
      apply_hrefs
    end

    attr_reader :directory, :name, :path_relative, :type,
                :view_href, :edit_href, :delete_href

    # Ensure relative directory starts with '/'
    def self.standardize_dir_relative(dir_relative)
      standardized = dir_relative
      standardized.prepend('/') unless standardized.start_with?('/')
      standardized
    end

    def self.type(path_absolute)
      return :directory if FileTest.directory?(path_absolute)
      return :file if FileTest.file?(path_absolute)

      :unknown
    end

    def self.entry_name_chars_allowed_message
      'Please use only numbers, letters, underscores, and periods for names.'
    end

    def self.dir_name_valid?(dir_name)
      !(dir_name =~ /\A[\w.]+\z/).nil?
    end

    def self.dir_names_valid?(names)
      names = entry_names_from_user_input(names) if names.is_a?(String)
      names.all?(&method(:dir_name_valid?))
    end

    def self.file_name_valid?(file_name)
      !(file_name =~ /\A[\w.]+\z/).nil?
    end

    def self.entry_names_from_user_input(input_string)
      input_string.split('/')
    end

    private

    def apply_hrefs
      apply_view_href
      apply_edit_href
      apply_delete_href
    end

    # Build "view" `href` attribute value based on entry type:
    # - Use `APP_ROUTES[:browse]` route for directories.
    # - Use `APP_ROUTES[:view]` route for files.
    def apply_view_href
      @view_href = case type
                   when :directory then "#{APP_ROUTES[:browse]}#{path_relative}"
                   when :file then "#{APP_ROUTES[:view]}#{path_relative}"
                   end
    end

    # Build "edit" `href` attribute value based on entry type:
    # - Use `APP_ROUTES[:edit]` route for files.
    # - Disable for directories (assign `nil`).
    def apply_edit_href
      @edit_href = case type
                   when :directory then nil
                   when :file then "#{APP_ROUTES[:edit]}#{path_relative}"
                   end
    end

    # Build "edit" `href` attribute value based on entry type:
    # - Use `APP_ROUTES[:edit]` route for files.
    # - Disable for directories (assign `nil`).
    def apply_delete_href
      @delete_href = case type
                     when :directory, :file
                       "#{APP_ROUTES[:delete]}#{path_relative}"
                     end
    end
  end
end
