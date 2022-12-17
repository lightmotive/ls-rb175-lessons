# frozen_string_literal: true

require_relative 'application_controller'

module Controllers
  # Handle 'APP_ROUTES[:edit]' routes.
  class EditController < ApplicationController
    def validate_edit_path(path)
      case content_entry_type(path)
      when :file
        path
      when :directory
        flash_error_message 'Editing not allowed.'
        redirect URLUtils.join_components(APP_ROUTES[:browse], path)
      else
        flash_error_message 'Entry not found.'
        redirect APP_ROUTES[:browse]
      end
    end

    # before 'APP_ROUTES[:edit]/*'
    before '/*' do
      validate_edit_path(current_location)
    end

    # Edit files
    # get 'APP_ROUTES[:edit]/*'
    get '/*' do
      file_path = content_path(current_location)
      @file_content = File.read(file_path)
      erb :edit
    end

    # Save submitted content to file, then redirect to file's directory.
    # post 'APP_ROUTES[:edit]/*'
    post '/*' do
      file_content = params[:file_content]

      content = Models::Content.new
      content.edit_file(current_location, file_content)

      flash_success_message "#{File.basename(current_location)} was updated."
      redirect URLUtils.join_components(
        APP_ROUTES[:browse], File.dirname(current_location)
      ), 303
    end
  end
end
