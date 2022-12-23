# frozen_string_literal: true

require_relative 'new_base_controller'
require './models/content_entry'

module Controllers
  # Create new directory
  class NewDirController < NewBaseController
    def initialize
      super

      @type = :dir
    end

    helpers do
      def allowed_input_message
        "#{super} Use '/' to separate paths."
      end
    end

    # Customize `new_entry` template to create directory in current location
    # get 'app_route(:new_dir)/'
    get '/' do
      erb :new_entry
    end

    # Validate and save submitted dir name, then redirect to current location.
    # post 'app_route(:new_dir)/'
    post '/' do
      input = params['entry_name']
      input_paths = Models::ContentEntry.entry_names_from_user_input(input)

      if Models::ContentEntry.dir_names_valid?(input_paths)
        content = Models::Content.new
        content.create_directory(File.join(current_location, input_paths))
        flash_message :success, "'#{input}' created successfully."
        redirect app_route(:browse, loc: current_location), 303
      else
        flash_message :error, [Models::ContentEntry.entry_name_chars_allowed_message,
                               "Use '/' to separate paths."]
        status 400
        erb :new_entry
      end
    end
  end
end
