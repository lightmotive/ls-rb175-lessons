# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Handle 'app_route(:edit)' routes.
  class EditController < ApplicationController
    def validate_edit_path(path)
      case current_location_entry_type
      when :directory
        flash_message :error, 'Editing not allowed.'
        redirect app_route(:browse, loc: path)
      end
    end

    def title
      "Edit #{super}"
    end

    # before 'app_route(:edit)/'
    before '/' do
      validate_edit_path(current_location)
    end

    # Edit files
    # get 'app_route(:edit)/'
    get '/' do
      file_path = content_absolute_path(current_location)
      @file_content = File.read(file_path)
      erb :edit
    end

    # Save submitted content to file, then redirect to file's directory.
    # post 'app_route(:edit)/'
    post '/' do
      file_content = params[:file_content]

      content = Models::Content.new
      content.edit_file(current_location, file_content)

      flash_message :success, "#{File.basename(current_location)} was updated."
      redirect app_route(:browse, loc: File.dirname(current_location)), 303
    end
  end
end
