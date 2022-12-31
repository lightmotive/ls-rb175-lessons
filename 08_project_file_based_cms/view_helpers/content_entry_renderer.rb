# frozen_string_literal: true

require './view_helpers/app/renderer'
require './cms_app_helper'
require './models/content_entry'

module ViewHelpers
  # Render content entry components.
  class ContentEntryRenderer < App::Renderer
    include CMSAppHelper

    def initialize(entry)
      super()

      @entry = entry
      generate_hrefs
    end

    attr_reader :entry, :view_href, :edit_href, :delete_href

    def generate_hrefs
      @view_href = generate_view_href
      @edit_href = generate_edit_href
      @delete_href = generate_delete_href
    end

    def render
      super(:content_entry)
    end

    private

    # Build "view" `href` attribute value based on entry type:
    # - Use `app_route(:browse)` route for directories.
    # - Use `app_route(:view)` route for files.
    def generate_view_href
      @view_href =
        case entry.type
        when :directory then app_route(:browse, loc: entry.path_relative)
        when :file then app_route(:view, loc: entry.path_relative)
        end
    end

    # Build "edit" `href` attribute value based on entry type:
    # - Use `app_route(:edit)` route for files.
    # - Disable for directories (assign `nil`).
    def generate_edit_href
      @edit_href =
        case entry.type
        when :directory then nil
        when :file then app_route(:edit, loc: entry.path_relative)
        end
    end

    # Build "edit" `href` attribute value based on entry type:
    # - Use `app_route(:edit)` route for files.
    # - Disable for directories (assign `nil`).
    def generate_delete_href
      @delete_href =
        case entry.type
        when :directory, :file
          app_route(:delete, loc: entry.path_relative)
        end
    end
  end
end
