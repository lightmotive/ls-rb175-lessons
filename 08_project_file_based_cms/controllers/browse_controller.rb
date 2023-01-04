# frozen_string_literal: true

require_relative 'application_controller'

# TODO: remaining tasks
# - Rename routes and associated classes that inherit BrowseController:
#   - Prefix route name with `:browse` and value with `/browse`.
#   - Prefix class names with `Browse`.
#   - Ensure routes are mapped before base `/browse` route.

module Controllers
  # Handle browse routes
  class BrowseController < ApplicationController
    attr_reader :entries

    def title
      "Browse #{super}"
    end

    helpers ViewHelpers::Browse, ViewHelpers::Upload, ViewHelpers::NewEntry

    def render_browse_template
      @entries = content_entries(current_location)
      erb :browse
    end

    # get 'app_route(:browse)/'
    # Get public content entries starting at current_location and render :browse if
    # :directory or redirect to view file if :file
    get '/' do
      case current_location_entry_type
      when :directory
        render_browse_template
      when :file
        redirect app_route(:view, loc: current_location)
      end
    end
  end
end
