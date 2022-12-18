# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Handle browse routes
  class BrowseController < ApplicationController
    def initialize
      super
      @new_directory_href = nil
      @new_file_href = nil
    end

    attr_reader :new_directory_href, :new_file_href

    helpers ViewHelpers::Browse

    # get 'app_route(:browse)/'
    # Get public content entries starting at current_location and render :browse if
    # :directory or redirect to view file if :file
    get '/' do
      case current_location_entry_type
      when :directory
        @entries = content_entries(current_location)
        enable_new_entries
        erb :browse
      when :file
        redirect app_route(:view, loc: current_location)
      end
    end

    def enable_new_entries
      @new_directory_href = app_route(:new_dir, loc: current_location)
      @new_file_href = app_route(:new_file, loc: current_location)
    end
  end
end
