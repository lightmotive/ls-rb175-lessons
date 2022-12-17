# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Handle 'app_route(:edit)' routes.
  class EditController < ApplicationController
    def validate_edit_path(path)
      case content_entry_type(path)
      when :file
        path
      when :directory
        flash_error_message 'Editing not allowed.'
        redirect app_route(:browse, loc: path)
      else
        flash_error_message 'Entry not found.'
        redirect app_route(:browse)
      end
    end

    # before 'app_route(:edit)/'
    before '/' do
      validate_edit_path(current_location)
    end

    # Edit files
    # get 'app_route(:edit)/'
    get '/' do
      file_path = content_path(current_location)
      @file_content = File.read(file_path)
      erb :edit
    end

    # Save submitted content to file, then redirect to file's directory.
    # post 'app_route(:edit)/'
    post '/' do
      file_content = params[:file_content]

      content = Models::Content.new
      content.edit_file(current_location, file_content)

      flash_success_message "#{File.basename(current_location)} was updated."
      redirect app_route(:browse, loc: File.dirname(current_location)), 303
    end
  end
end
