# frozen_string_literal: true

require_relative 'application_controller'

# TODO:
# - Extract `browse.erb` dependencies to `Browseable` module for inclusion in
#   both `BrowseController` and `NewEntryController`. Then, `NewEntryController`
#   can inherit from `ApplicationController`. That clarifies intent and shortens
#   the inheritance chain.
# - Enable editing entry names.
#   - Skip JavaScript enhancement for now.
#   - Write and edit tests first this time. Make that a habit!
#   - Use the BrowseController; think about how to handle that before writing
#     tests or logic...
#     - Add a `/rename` route to `BrowseController`:
#       - `get '/'`: Add a new "rename" icon to all entries that will submit the
#          `/rename` get request. All entries will be renamable.
#         - Reload the page on click. Don't worry about maintaining scroll
#           position for now; that won't be an issue when using AJAX to update
#           the element without reloading the page.
#         - To determine which entry to rename, implement a new entry enumerator
#           that checks the entry name to edit, if any; when matched, render
#           the entry as an edit form (component).
#           - autofocus the input.
#       - `get '/rename'`
#         - Render `browse.erb` with the entry for the clicked edit button
#           rendered as an edit form.
#       - `post '/rename'`: apply the submitted form data.

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
