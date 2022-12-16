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
    # get 'APP_ROUTES[:new_dir]/*'
    get '/*' do
      erb :new_entry
    end

    # Validate and save submitted file name, then redirect to file's directory.
    # post 'APP_ROUTES[:new_file]/*'
    post '/*' do
      input_name = params['entry_name']

      if Models::ContentEntry.file_name_valid?(input_name)
        content = Models::Content.new
        content.create_file(File.join(current_location, input_name))
        redirect_to_current_location
      else
        session[:error] = Models::ContentEntry.entry_name_chars_allowed_message
        erb :new_entry
      end
    end
  end
end
