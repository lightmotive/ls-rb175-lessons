# frozen_string_literal: true

require './models/content_entry'

module ViewHelpers
  # New Entry form helpers.
  module NewEntry
    def new_entry_post_route
      app_route(:new_entry, loc: current_location)
    end

    def allowed_input_message
      "#{Models::ContentEntry.entry_name_chars_allowed_message} #{
       Models::ContentEntry.separate_entries_message}"
    end
  end
end
