# frozen_string_literal: true

require_relative 'new_base_controller'
require './models/content'

module Controllers
  # Create new file
  class NewFileController < NewBaseController
    def initialize
      super

      @type = :file
    end

    def title
      "Create File in #{super}"
    end

    # Validate and save submitted file name, then redirect to file's directory.
    # post 'app_route(:new_file)/'
    post '/' do
      input_name = params['entry_name']

      if Models::ContentEntry.file_name_allowed?(input_name)
        content = Models::Content.new
        content.create_file(File.join(current_location, input_name))
        flash_message :success, "'#{input_name}' created successfully."
        redirect app_route(:browse, loc: current_location), 303
      else
        flash_message :error, Models::ContentEntry.entry_name_chars_allowed_message
        status 400
        erb :new_entry
      end
    end
  end
end
