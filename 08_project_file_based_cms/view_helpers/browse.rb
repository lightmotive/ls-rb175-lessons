# frozen_string_literal: true

require './app/url_utils'
require_relative 'content_entry_component'

module ViewHelpers
  # Browse controller helpers.
  module Browse
    def render_content_entry(entry)
      ContentEntryComponent.new(entry).render.chomp
    end
  end
end
