# frozen_string_literal: true

require_relative 'application_controller'

# TODO:
# - Extract `browse.erb` dependencies to `Browsable` module for inclusion in
#   both `BrowseController` and `NewEntryController`. Then, `NewEntryController`
#   can inherit from `ApplicationController` (shorten inheritance chain).
# - Enable editing directory names.
#   - Skip JavaScript enhancement for now.
#   - Write and edit tests first this time. Make that a habit!
#   - Probably use the EditController: render `browse.erb`,
#     ensuring that the entry for the clicked edit button renders as an edit
#     form. Think about how to handle that before writing tests or logic...
#     - How about adding an `/rename` route to the `/browse` route (controller)
#       that posts the name of the entry? Add a new "rename" icon to submit the
#       `/rename` request. All entries will be renamable.
#     - To determine which entry to rename, implement a new entry enumerator
#       that checks the entry name to edit; when it matches, flag the entry
#       so it renders as an edit form (component).
#       - autofocus the input
#     - Reload the page on click. Don't worry about maintaining scroll position for now.

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
