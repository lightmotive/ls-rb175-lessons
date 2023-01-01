# frozen_string_literal: true

require './models/content_entry'

module ViewHelpers
  # Upload form helpers.
  module Upload
    def upload_action(current_location)
      app_route(:upload, loc: current_location)
    end

    def upload_input_accept
      file_types = Models::ContentEntry.file_types_allowed
      mime_types = file_types.values.map { |data| data[:content_type] }
      mime_types.join(', ')
    end
  end
end
