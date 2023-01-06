# frozen_string_literal: true

require_relative 'application_controller'

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
