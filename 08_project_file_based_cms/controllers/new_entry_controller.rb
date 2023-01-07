# frozen_string_literal: true

require_relative 'browse_controller'
require './models/content_entry'

module Controllers
  # Create new file system entries.
  class NewEntryController < BrowseController
    def initialize
      super

      @type = nil
      @name = nil
    end

    attr_reader :type, :name

    helpers ViewHelpers::NewEntry

    before '*' do
      @type = params[:new_entry_type]
      @name = params[:new_entry_name]
    end

    # post 'app_route(:new_entry)/'
    post '/' do
      case type
      when 'directory' then post_directory
      when 'file' then post_file
      end
    end

    private

    # Validate and save submitted dir name, then redirect to current location.
    def post_directory
      create_directory(name, in_loc: current_location)
      flash_message :success, "'#{name}' created successfully."
      redirect app_route(:browse, loc: current_location), 303
    rescue Models::ContentError => e
      handle_invalid_input e.message
    end

    # Validate and save submitted file name, then redirect to file's directory.
    def post_file
      create_file(name, in_loc: current_location)
      flash_message :success, "'#{name}' created successfully."
      redirect app_route(:browse, loc: current_location), 303
    rescue Models::ContentError => e
      handle_invalid_input e.message
    end

    def handle_invalid_input(error_messages)
      flash_message :error, error_messages
      status 400
      render_browse_template
    end
  end
end
