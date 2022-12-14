# frozen_string_literal: true

module Models
  # Content Entry (file system) model with paths relative to application's
  # `./content` directory.
  class ContentEntry
    def initialize(dir_relative:, basename:, path_absolute:)
      @directory = dir_relative.empty? ? '/' : dir_relative
      @name = basename
      @type = ContentEntry.type(path_absolute)
      apply_view_href
      apply_edit_href
    end

    attr_reader :directory, :name, :type, :view_href, :edit_href

    def self.type(path_absolute)
      return :directory if FileTest.directory?(path_absolute)
      return :file if FileTest.file?(path_absolute)

      :unknown
    end

    private

    # Build "view" `href` attribute value based on entry type:
    # - Use `APP_ROUTES[:browse]` route for directories.
    # - Use `APP_ROUTES[:view]` route for files.
    def apply_view_href
      path_relative = File.join(directory, name)
      @view_href = case type
                   when :directory then URLUtils.join_components(APP_ROUTES[:browse], path_relative)
                   when :file then URLUtils.join_components(APP_ROUTES[:view], path_relative)
                   end
    end

    # Build "edit" `href` attribute value based on entry type:
    # - Use `APP_ROUTES[:edit]` route for files.
    # - Disable for directories (assign `nil`).
    def apply_edit_href
      path_relative = File.join(directory, name)
      @edit_href = case type
                   when :directory then nil
                   when :file then URLUtils.join_components(APP_ROUTES[:edit], path_relative)
                   end
    end
  end
end
