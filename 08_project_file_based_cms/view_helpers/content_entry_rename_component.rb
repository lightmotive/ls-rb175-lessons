# frozen_string_literal: true

require './view_helpers/component'
require './app/core'

module ViewHelpers
  # Render form for renaming a content entry.
  class ContentEntryRenameComponent < Component
    include AppRoutes

    def initialize(entry, loc:, params:)
      super()

      @entry = entry
      @location = loc
      @params = params
      generate_hrefs
    end

    attr_reader :entry, :location, :params, :rename_action, :cancel_href

    # Genertate href/action request URIs based on attributes like entry type and
    # content type-specific allowed actions.
    def generate_hrefs
      @rename_action = generate_rename_action
      @cancel_href = generate_cancel_href
    end

    def render(template: :content_entry_rename_component)
      super(template)
    end

    private

    def generate_rename_action
      return unless entry.action_allowed?(:rename) && entry.type_supported?

      @rename_action = app_route(
        :rename_entry,
        loc: location,
        other_query_params: { entry_name: entry.name }
      )
    end

    def generate_cancel_href
      @cancel_href = app_route(:browse, loc: location)
    end
  end
end
