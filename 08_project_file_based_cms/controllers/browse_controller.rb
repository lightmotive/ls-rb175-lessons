# frozen_string_literal: true

require_relative 'application_controller'

# TODO:
# - Convert New Directory and New File links to a single form directly in Browse page.
#   - Use select element to choose `file` or `directory`.
#   - On error, remember to retain what the user entered, including the select
#     element's value.
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
      @new_directory_href = nil
      @new_file_href = nil
    end

    attr_reader :new_directory_href, :new_file_href

    def title
      "Browse #{super}"
    end

    helpers ViewHelpers::Browse, ViewHelpers::Upload

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
