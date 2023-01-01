# frozen_string_literal: true

require './view_helpers/component'
require './cms_app_helper'

module ViewHelpers
  # Render content entry components.
  class ContentEntryComponent < Component
    include CMSAppHelper

    def initialize(entry)
      super()

      @entry = entry
      generate_hrefs
    end

    attr_reader :entry, :view_href, :edit_href, :delete_action

    def generate_hrefs
      @view_href = generate_view_href
      @edit_href = generate_edit_href
      @delete_action = generate_delete_action
    end

    def render(template: :content_entry_component)
      super(template)
    end

    private

    # Build "view" `href` attribute value based on entry type:
    # - Use `app_route(:browse)` route for directories.
    # - Use `app_route(:view)` route for files.
    def generate_view_href
      return unless entry.actions.include?(:view)

      @view_href =
        case entry.type
        when :directory then app_route(:browse, loc: entry.path_relative)
        when :file then app_route(:view, loc: entry.path_relative)
        end
    end

    # Build "edit" `href` attribute value based on entry's actions.
    # - Use `app_route(:edit)` route for files.
    def generate_edit_href
      return unless entry.actions.include?(:edit)

      @edit_href = app_route(:edit, loc: entry.path_relative)
    end

    # Build "delete" `action` attribute value based on entry's actions.
    # - Use `app_route(:edit)` route for files.
    def generate_delete_action
      return unless entry.actions.include?(:delete)

      @delete_action = app_route(:delete, loc: entry.path_relative)
    end
  end
end
