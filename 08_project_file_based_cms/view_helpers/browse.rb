# frozen_string_literal: true

require './url_utils'
require './models/content_entry'

module ViewHelpers
  # Global app helpers
  module Browse
    def navigation_path(current_location = '/')
      return '' if current_location == '/' || current_location.empty?

      nav_path = "<a href=\"#{app_route(:browse)}\">home</a>"

      dir_names = current_location[1..].split('/')
      locations = []
      dir_names[0..-2].each do |name|
        locations << name
        nav_path += "/<a href=\"#{app_route(:browse, loc: locations.join('/'))}\">#{name}</a>"
      end

      nav_path += "/#{dir_names.last}"
      nav_path
    end

    # Build "view" `href` attribute value based on entry type:
    # - Use `app_route(:browse)` route for directories.
    # - Use `app_route(:view)` route for files.
    def entry_view_href(entry)
      case entry.type
      when :directory then app_route(:browse, loc: entry.path_relative)
      when :file then app_route(:view, loc: entry.path_relative)
      end
    end

    # Build "edit" `href` attribute value based on entry type:
    # - Use `app_route(:edit)` route for files.
    # - Disable for directories (assign `nil`).
    def entry_edit_href(entry)
      case entry.type
      when :directory then nil
      when :file then app_route(:edit, loc: entry.path_relative)
      end
    end

    # Build "edit" `href` attribute value based on entry type:
    # - Use `app_route(:edit)` route for files.
    # - Disable for directories (assign `nil`).
    def entry_delete_href(entry)
      case entry.type
      when :directory, :file
        app_route(:delete, loc: entry.path_relative)
      end
    end

    def upload_href(current_location)
      app_route(:upload, loc: current_location)
    end

    def uploads_input_accept
      file_types = Models::ContentEntry.file_types_allowed
      mime_types = file_types.values.map { |data| data[:content_type] }
      mime_types.join(', ')
    end
  end
end
