# frozen_string_literal: true

require_relative 'browse_controller'
require './models/content_entry'

module Controllers
  # Create new file system entries.
  class RenameEntryController < BrowseController
    # - IN-PROGRESS: Write tests for the following:
    # *********************************************
    #   - Upon clicking 'rename':
    #     - [Test(s) written? No] `get app_route(:rename_entry, loc: current_location)`
    #       - [Test(s) written? No] If request is not XHR, flash error indicating that
    #         "Please enable JavaScript to rename entries."
    #       - [Test(s) written? need to check...] Request query string:
    #         `loc=current_location` & `rename_entry=relative_path_to_entry`
    #       - [Test(s) written? No] If entry found, return the HTML for the entry
    #         rendered as a form using new method in `ContentEntryComponent` class.
    #       - [Test(s) written? No] If entry not found, flash error and redirect
    #         to browse current location.
    #   - `post app_route(:rename_entry, loc: current_location)`: apply the
    #      submitted form data.
    #     - [Test(s) written? No] Request query string: `loc=current_location`;
    #       POST form data: `rename_entry=relative_path_to_entry` &
    #       `new_entry_name=new_relative_path_to_entry`.
    #     - [Test(s) written? No] On success, flash success.
    #     - [Test(s) written? No] On failure, flash error.
    #     - [Test(s) written? No] On success or failure, redirect to current location.
  end
end
