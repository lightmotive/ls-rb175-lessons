# frozen_string_literal: true

require_relative 'application_controller'

# TODO:
# - Enable editing entry names.
#   - Use AJAX to get the rename entry form. There's just no better way.
#   - Write and edit tests first this time. Make that a habit!
#   - [Test(s) written? Yes] `GET '/browse'`: Add a new "rename" icon to all
#     entries that will submit the `/rename` get request. All entries will be
#     renamable.
#   - Create a new RenameEntryController; think about how to handle that before
#     writing tests or logic...
# - Rename routes and associated classes that inherit BrowseController:
#   - Prefix route name with `:browse` and value with `/browse`.
#   - Prefix class names with `Browse`.
#   - Ensure routes are mapped before base `/browse` route.

module Controllers
  # Handle browse routes
  class BrowseController < ApplicationController
    def initialize
      super
    end

    attr_reader :entries

    def title
      "Browse #{super}"
    end

    helpers ViewHelpers::Browse, ViewHelpers::Upload, ViewHelpers::NewEntry

    before '*' do
      @entries = content_entries(current_location) if content_directory?(current_location)
    end

    # get 'app_route(:browse)/'
    # Get public content entries starting at current_location and render :browse if
    # :directory or redirect to view file if :file
    get '/' do
      case current_location_entry_type
      when :directory
        erb :browse
      when :file
        redirect app_route(:view, loc: current_location)
      end
    end
  end
end
