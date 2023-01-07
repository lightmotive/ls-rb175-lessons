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

    attr_reader :entry, :view_href, :rename_href, :edit_href, :delete_action

    # Genertate href/action request URIs based on attributes like entry type and
    # content type-specific allowed actions.
    def generate_hrefs
      @view_href = generate_view_href
      @rename_href = generate_rename_href
      @edit_href = generate_edit_href
      @delete_action = generate_delete_action
    end

    def render(template: :content_entry_component)
      super(template)
    end

    private

    def generate_view_href
      return unless entry.action_allowed?(:view) && entry.type_supported?

      @view_href =
        case entry.type
        when :directory then app_route(:browse, loc: entry.path_relative)
        when :file then app_route(:view, loc: entry.path_relative)
        end
    end

    def generate_rename_href
      return unless entry.action_allowed?(:rename) && entry.type_supported?

      @rename_href = app_route(
        :rename_entry,
        loc: entry.directory,
        other_query_params: { entry_name: entry.name }
      )
    end

    def generate_edit_href
      return unless entry.action_allowed?(:edit) && entry.type_supported?

      @edit_href = app_route(:edit, loc: entry.path_relative)
    end

    def generate_delete_action
      return unless entry.action_allowed?(:delete) && entry.type_supported?

      @delete_action = app_route(:delete, loc: entry.path_relative)
    end
  end
end
