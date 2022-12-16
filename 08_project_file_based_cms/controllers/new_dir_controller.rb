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
    # get 'APP_ROUTES[:new_dir]/*'
    get '/*' do
      erb :new_entry
    end

    # Validate and save submitted dir name, then redirect to current location.
    # post 'APP_ROUTES[:new_dir]/*'
    post '/*' do
      input_path = Models::ContentEntry.entry_names_from_user_input(params['entry_name'])

      if Models::ContentEntry.dir_names_valid?(input_path)
        content = Models::Content.new
        content.create_directory(File.join(current_location, input_path))
        redirect_to_current_location
      else
        session[:error] = [Models::ContentEntry.entry_name_chars_allowed_message,
                           "Use '/' to separate paths."]
        erb :new_entry
      end
    end
  end
end
