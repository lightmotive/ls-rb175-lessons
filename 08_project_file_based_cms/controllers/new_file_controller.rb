# frozen_string_literal: true

require_relative 'new_base_controller'
require './models/content_entry'

module Controllers
  # Create new file
  class NewFileController < NewBaseController
    def initialize
      super

      @type = :file
    end

    # Customize `new_entry` template to create directory in current location
    # get 'app_route(:new_dir)/*'
    get '/*' do
      erb :new_entry
    end

    # Validate and save submitted file name, then redirect to file's directory.
    # post 'app_route(:new_file)/*'
    post '/*' do
      input_name = params['entry_name']

      if Models::ContentEntry.file_name_valid?(input_name)
        content = Models::Content.new
        content.create_file(File.join(current_location, input_name))
        flash_success_message "'#{input_name}' created successfully."
        redirect app_route(:browse, current_location)
      else
        flash_error_message Models::ContentEntry.entry_name_chars_allowed_message
        status 400
        erb :new_entry
      end
    end
  end
end
