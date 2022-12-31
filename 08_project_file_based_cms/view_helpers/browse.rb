# frozen_string_literal: true

require './url_utils'
require_relative 'content_entry_component'

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

    def render_content_entry(entry)
      ContentEntryComponent.new(entry).render.chomp
    end

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
